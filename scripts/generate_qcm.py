#!/usr/bin/env python3
"""
Generate QCM (Questionnaire) for GitHub Issues using Gemini

This script generates a customized questionnaire based on the issue type
to help clarify specifications before implementation.
"""

import os
import sys
import json
import argparse
import requests
from typing import Dict, Any, List, Optional


class GeminiQCMGenerator:
    """Generate QCM using Gemini AI"""

    def __init__(self, api_key: str):
        self.api_key = api_key
        self.api_url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"

    def get_issue_details(self, owner: str, repo: str, issue_number: int, token: str) -> Dict[str, Any]:
        """Fetch issue details from GitHub API"""
        url = f"https://api.github.com/repos/{owner}/{repo}/issues/{issue_number}"
        headers = {
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github.v3+json",
        }

        response = requests.get(url, headers=headers)
        response.raise_for_status()
        return response.json()

    def determine_issue_type(self, labels: List[Dict[str, str]]) -> str:
        """Determine issue type from labels"""
        for label in labels:
            label_name = label.get("name", "").lower()
            if "type:feature" in label_name:
                return "feature"
            elif "type:bug" in label_name:
                return "bug"
            elif "type:task" in label_name:
                return "task"
        return "general"

    def generate_qcm(self, issue_data: Dict[str, Any]) -> str:
        """Generate QCM using Gemini based on issue details"""
        issue_type = self.determine_issue_type(issue_data.get("labels", []))
        issue_title = issue_data.get("title", "")
        issue_body = issue_data.get("body", "")
        issue_number = issue_data.get("number", "")

        # Construct prompt for Gemini
        prompt = self._build_prompt(issue_type, issue_title, issue_body, issue_number)

        # Call Gemini API
        try:
            qcm_content = self._call_gemini_api(prompt)
            return qcm_content
        except Exception as e:
            print(f"❌ Error calling Gemini API: {e}")
            # Fallback to template-based QCM
            return self._generate_template_qcm(issue_type, issue_title, issue_number)

    def _build_prompt(self, issue_type: str, title: str, body: str, issue_number: int) -> str:
        """Build prompt for Gemini to generate relevant questions"""
        base_prompt = f"""You are a technical project manager helping to clarify requirements for a GitHub issue.

**Issue #{issue_number}: {title}**

**Issue Type:** {issue_type}

**Issue Description:**
{body}

---

Generate a questionnaire (QCM) with 3-5 well-thought questions to help clarify the specifications before implementation.

**Requirements:**
1. Questions should be specific to the issue content
2. Questions should help clarify ambiguities and technical details
3. Each question should have:
   - A clear, concise question text
   - 3-5 multiple choice options (or indicate if open-ended)
   - Context explaining why this question matters
4. Include one open-ended question at the end for additional notes
5. Format the output in Markdown

**Question Focus Areas by Type:**"""

        if issue_type == "feature":
            base_prompt += """
- User experience and interface details
- Technical implementation approach
- Edge cases and error handling
- Integration with existing features
- Performance and scalability considerations"""
        elif issue_type == "bug":
            base_prompt += """
- Reproduction steps clarification
- Impact and severity assessment
- Root cause investigation
- Proposed fix approach
- Regression testing requirements"""
        elif issue_type == "task":
            base_prompt += """
- Technical approach and architecture
- Dependencies and blockers
- Success criteria and deliverables
- Timeline and milestones
- Documentation requirements"""
        else:
            base_prompt += """
- Scope and objectives
- Technical requirements
- Success criteria
- Dependencies
- Timeline expectations"""

        base_prompt += """

**Output Format:**
Use this markdown structure:

## 🎯 Questionnaire de Spécification

> Ce questionnaire vous aide à préciser les détails de cette issue avant l'implémentation.

### Question 1: [Question Title]

**Contexte:** [Why this question matters]

- [ ] Option A: [Description]
- [ ] Option B: [Description]
- [ ] Option C: [Description]
- [ ] Option D: [Description]

### Question 2: [Question Title]
...

### Question Ouverte: Informations Supplémentaires

**Y a-t-il des détails importants que nous devrions considérer ?**

[Espace pour réponse libre]

---

**Instructions:** Veuillez cocher les options pertinentes et ajouter vos commentaires. Une fois complété, nous pourrons démarrer l'implémentation avec toutes les informations nécessaires.

Generate ONLY the questionnaire in Markdown format. Do not include any explanations before or after."""

        return base_prompt

    def _call_gemini_api(self, prompt: str) -> str:
        """Call Gemini API to generate content"""
        url = f"{self.api_url}?key={self.api_key}"

        payload = {
            "contents": [
                {
                    "parts": [
                        {"text": prompt}
                    ]
                }
            ],
            "generationConfig": {
                "temperature": 0.7,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 2048,
            }
        }

        headers = {
            "Content-Type": "application/json"
        }

        response = requests.post(url, json=payload, headers=headers)
        response.raise_for_status()

        result = response.json()

        # Extract generated text
        if "candidates" in result and len(result["candidates"]) > 0:
            candidate = result["candidates"][0]
            if "content" in candidate and "parts" in candidate["content"]:
                parts = candidate["content"]["parts"]
                if len(parts) > 0 and "text" in parts[0]:
                    return parts[0]["text"]

        raise Exception(f"Unexpected API response structure: {result}")

    def _generate_template_qcm(self, issue_type: str, title: str, issue_number: int) -> str:
        """Generate template-based QCM as fallback"""
        templates = {
            "feature": """## 🎯 Questionnaire de Spécification - Feature

> Ce questionnaire vous aide à préciser les détails de cette fonctionnalité avant l'implémentation.

### Question 1: Périmètre de la Feature

**Contexte:** Clarifier les limites et l'étendue de la fonctionnalité.

- [ ] Option A: Feature minimale (MVP) avec fonctionnalités de base uniquement
- [ ] Option B: Feature complète avec toutes les fonctionnalités décrites
- [ ] Option C: Feature extensive avec des améliorations additionnelles
- [ ] Autre: _[Veuillez préciser]_

### Question 2: Interface Utilisateur

**Contexte:** Définir l'expérience utilisateur attendue.

- [ ] Option A: Interface graphique complète avec tous les éléments visuels
- [ ] Option B: Interface minimale fonctionnelle
- [ ] Option C: API/CLI uniquement (pas d'interface graphique)
- [ ] Option D: Réutiliser un composant existant avec modifications
- [ ] Autre: _[Veuillez préciser]_

### Question 3: Intégration et Dépendances

**Contexte:** Identifier les systèmes et fonctionnalités existants affectés.

- [ ] Option A: Feature isolée, aucune dépendance majeure
- [ ] Option B: Intégration avec des fonctionnalités existantes
- [ ] Option C: Nécessite des modifications d'architecture
- [ ] Option D: Dépend de features externes ou APIs tierces
- [ ] Autre: _[Veuillez préciser]_

### Question 4: Performance et Scalabilité

**Contexte:** Anticiper les besoins en performance.

- [ ] Option A: Performance standard, volume de données faible
- [ ] Option B: Performance importante, gros volumes attendus
- [ ] Option C: Temps réel requis
- [ ] Option D: Optimisations spécifiques nécessaires
- [ ] Autre: _[Veuillez préciser]_

### Question Ouverte: Informations Supplémentaires

**Y a-t-il des détails importants, contraintes techniques, ou considérations de sécurité que nous devrions prendre en compte ?**

_[Votre réponse ici]_

---

**Instructions:** Veuillez cocher les options pertinentes et ajouter vos commentaires. Une fois complété, nous pourrons démarrer l'implémentation avec toutes les informations nécessaires.
""",
            "bug": """## 🐛 Questionnaire de Spécification - Bug

> Ce questionnaire vous aide à préciser les détails de ce bug avant la correction.

### Question 1: Sévérité et Impact

**Contexte:** Évaluer la priorité de correction.

- [ ] Option A: Critique - Bloque l'utilisation ou perte de données
- [ ] Option B: Haute - Fonctionnalité importante affectée
- [ ] Option C: Moyenne - Fonctionnalité utilisable avec contournement
- [ ] Option D: Basse - Problème cosmétique ou mineur
- [ ] Autre: _[Veuillez préciser]_

### Question 2: Reproductibilité

**Contexte:** Comprendre la fréquence du bug.

- [ ] Option A: Toujours reproductible avec les étapes fournies
- [ ] Option B: Reproductible dans certaines conditions
- [ ] Option C: Intermittent et difficile à reproduire
- [ ] Option D: Observé une seule fois
- [ ] Autre: _[Veuillez préciser]_

### Question 3: Environnement Affecté

**Contexte:** Identifier les environnements impactés.

- [ ] Option A: Production uniquement
- [ ] Option B: Tous les environnements (dev, staging, prod)
- [ ] Option C: Environnements de développement uniquement
- [ ] Option D: Configuration ou navigateur spécifique
- [ ] Autre: _[Veuillez préciser]_

### Question 4: Approche de Correction Préférée

**Contexte:** Définir la stratégie de résolution.

- [ ] Option A: Correction rapide (hotfix)
- [ ] Option B: Correction complète avec refactoring
- [ ] Option C: Workaround temporaire puis correction dans une release future
- [ ] Option D: Investigation approfondie requise avant correction
- [ ] Autre: _[Veuillez préciser]_

### Question Ouverte: Informations Supplémentaires

**Y a-t-il des logs, stack traces, ou informations de debugging additionnelles disponibles ?**

_[Votre réponse ici]_

---

**Instructions:** Veuillez cocher les options pertinentes et ajouter vos commentaires. Une fois complété, nous pourrons démarrer la correction avec toutes les informations nécessaires.
""",
            "task": """## 📋 Questionnaire de Spécification - Task

> Ce questionnaire vous aide à préciser les détails de cette tâche avant l'exécution.

### Question 1: Objectif Principal

**Contexte:** Clarifier le but de cette tâche.

- [ ] Option A: Refactoring / Amélioration de code existant
- [ ] Option B: Configuration / Setup d'infrastructure
- [ ] Option C: Documentation technique
- [ ] Option D: Dette technique / Optimisation
- [ ] Autre: _[Veuillez préciser]_

### Question 2: Approche Technique

**Contexte:** Définir la méthode d'exécution.

- [ ] Option A: Suivre un plan technique spécifique (à détailler)
- [ ] Option B: Investigation puis proposition d'approche
- [ ] Option C: Implémentation standard avec best practices
- [ ] Option D: POC/Prototype d'abord
- [ ] Autre: _[Veuillez préciser]_

### Question 3: Dépendances et Blocages

**Contexte:** Identifier les prérequis.

- [ ] Option A: Aucune dépendance, peut démarrer immédiatement
- [ ] Option B: Dépend d'autres issues en cours
- [ ] Option C: Nécessite validation/approbation avant de commencer
- [ ] Option D: Requiert des ressources externes (accès, credentials, etc.)
- [ ] Autre: _[Veuillez préciser]_

### Question 4: Critères de Succès

**Contexte:** Définir les livrables attendus.

- [ ] Option A: Code fonctionnel avec tests
- [ ] Option B: Documentation complète
- [ ] Option C: Configuration déployée et validée
- [ ] Option D: Metrics/Benchmarks d'amélioration
- [ ] Autre: _[Veuillez préciser]_

### Question Ouverte: Informations Supplémentaires

**Y a-t-il des contraintes de temps, de budget, ou des considérations techniques spécifiques pour cette tâche ?**

_[Votre réponse ici]_

---

**Instructions:** Veuillez cocher les options pertinentes et ajouter vos commentaires. Une fois complété, nous pourrons démarrer l'exécution avec toutes les informations nécessaires.
"""
        }

        template = templates.get(issue_type, templates["task"])
        return f"# Issue #{issue_number}: {title}\n\n{template}"

    def post_comment_to_issue(
        self,
        owner: str,
        repo: str,
        issue_number: int,
        comment: str,
        token: str
    ) -> bool:
        """Post QCM as a comment on the issue"""
        url = f"https://api.github.com/repos/{owner}/{repo}/issues/{issue_number}/comments"
        headers = {
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github.v3+json",
        }

        payload = {"body": comment}

        try:
            response = requests.post(url, json=payload, headers=headers)
            response.raise_for_status()
            print(f"✅ Comment posted successfully to issue #{issue_number}")
            return True
        except Exception as e:
            print(f"❌ Failed to post comment: {e}")
            return False


def main():
    parser = argparse.ArgumentParser(
        description="Generate QCM for GitHub issue using Gemini"
    )
    parser.add_argument("--issue", type=int, required=True, help="Issue number")
    parser.add_argument("--owner", help="Repository owner (default: from env)")
    parser.add_argument("--repo", help="Repository name (default: from env)")
    parser.add_argument("--post-comment", action="store_true", help="Post QCM as comment on issue")
    parser.add_argument("--output", help="Output file for QCM (optional)")

    args = parser.parse_args()

    # Get credentials from environment
    gemini_api_key = os.getenv("GEMINI_API_KEY")
    github_token = os.getenv("GH_TOKEN") or os.getenv("GITHUB_TOKEN")
    owner = args.owner or os.getenv("GH_OWNER") or os.getenv("GITHUB_REPOSITORY_OWNER")
    repo = args.repo or os.getenv("GH_REPO") or os.getenv("GITHUB_REPOSITORY", "").split("/")[-1]

    if not gemini_api_key:
        print("❌ GEMINI_API_KEY environment variable not set")
        print("📚 See: https://ai.google.dev/gemini-api/docs/api-key")
        sys.exit(1)

    if not github_token:
        print("❌ GH_TOKEN or GITHUB_TOKEN environment variable not set")
        sys.exit(1)

    if not owner or not repo:
        print("❌ Could not determine repository owner/name")
        print("Set GH_OWNER and GH_REPO environment variables")
        sys.exit(1)

    # Initialize generator
    generator = GeminiQCMGenerator(gemini_api_key)

    try:
        # Fetch issue details
        print(f"📥 Fetching issue #{args.issue} from {owner}/{repo}...")
        issue_data = generator.get_issue_details(owner, repo, args.issue, github_token)

        # Generate QCM
        print(f"🤖 Generating QCM using Gemini AI...")
        qcm_content = generator.generate_qcm(issue_data)

        # Output QCM
        if args.output:
            with open(args.output, "w", encoding="utf-8") as f:
                f.write(qcm_content)
            print(f"✅ QCM saved to {args.output}")
        else:
            print("\n" + "="*80)
            print(qcm_content)
            print("="*80 + "\n")

        # Post as comment if requested
        if args.post_comment:
            print(f"📤 Posting QCM as comment on issue #{args.issue}...")
            success = generator.post_comment_to_issue(
                owner, repo, args.issue, qcm_content, github_token
            )
            if not success:
                sys.exit(1)

        print("✅ QCM generation completed successfully")

    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
