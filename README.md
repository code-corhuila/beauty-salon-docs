# Beauty Salon

Beauty salon appointment booking and management app

---

> ### 📌 Política de ramas de este repositorio
>
> **Este repositorio de documentación es el ÚNICO del proyecto que NO usa ramas: se trabaja siempre y solo sobre `main`.**
>
> Se hace así a propósito, para **evitar incongruencias en la documentación** mientras el equipo sube cambios en paralelo. Toda edición de estos documentos se realiza y se commitea directamente a `main`.
>
> ⚠️ **Los demás repositorios del proyecto (el código de la app) SÍ deben seguir la estrategia de ramas** definida en [`00-governance/git-conventions.md`](./00-governance/git-conventions.md): ramas de feature, pull requests y revisión antes de hacer merge.

---

## Manual de documentación — Mobile Governance Framework

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![jesusarielgb-works](https://img.shields.io/badge/org-jesusarielgb--works-blue)](https://github.com/jesusarielgb-works)

> Documentation manual and governance scaffold for **mobile applications** — stack-agnostic
> (Flutter, React Native, native iOS, native Android). A lighter companion to the
> microservices framework: the same manual-with-templates approach, fewer sections.

**Author:** [Jesus Ariel Gonzalez Bonilla](https://github.com/jesusarielgb-works)

This repository is a **documentation scaffold** for any mobile project. It contains no
project-specific information. Its purpose is to teach how to govern and document a mobile
app professionally — showing what goes in each section, why it matters, and how the
sections relate.

---

## How to use this framework

1. **Fork** (or copy the structure) into your project repository.
2. **Read** [`00-sdd-guide.md`](./00-sdd-guide.md) for the fill-in order and methodology.
3. **Read each section `README.md`** before filling in its documents — they explain what is expected.
4. **Copy the `_template-*` files** when you need to document a concrete feature, screen,
   decision, endpoint, entity, test case, or release. Fill in, rename, keep the original template.
5. **Adapt every neutral rule** to your concrete stack (Flutter / React Native / native).
6. Once a document is complete, remove the instruction blocks.

---

## Build flow — section dependencies

> `00-governance` wraps the entire project and applies to every section.

```mermaid
graph TD
    subgraph PROCESS["🔵 PROCESS"]
        G0["00-governance\nagile · git · DoR/DoD · security rules"]
    end

    subgraph DESIGN["🟢 DESIGN"]
        A1["01-architecture\nstructure · layers · state · navigation · ADRs"]
        A2["02-code-and-ui\ncoding standards · design system · a11y · i18n"]
    end

    subgraph RULES["🟣 RULES"]
        A3["03-api-and-data\nnetworking · auth · persistence · offline"]
    end

    subgraph DELIVERY["🟠 DELIVERY"]
        A4["04-quality\ntesting · performance · security"]
        A5["05-release\nCI/CD · signing · stores · observability"]
    end

    G0 --> A1 --> A2 --> A3 --> A4 --> A5
```

---

## Sections

| # | Section | Content |
|---|---------|---------|
| [00](./00-governance/) | Governance | Agile process, git conventions, DoR/DoD, security rules |
| [01](./01-architecture/) | Architecture | Project structure, layers, state, navigation, ADRs |
| [02](./02-code-and-ui/) | Code & UI | Coding standards, design system, accessibility, i18n |
| [03](./03-api-and-data/) | API & Data | Networking, auth, persistence, offline & sync |
| [04](./04-quality/) | Quality | Testing strategy, performance budgets, mobile security |
| [05](./05-release/) | Release | CI/CD, signing, store distribution, observability |

Companions:
[monolith-governance-framework](https://github.com/jesusarielgb-works/monolith-governance-framework) ·
[microservices-governance-framework](https://github.com/jesusarielgb-works/microservices-governance-framework)

---

## How to Cite

> Gonzalez Bonilla, J. A. (2026). *Mobile Governance Framework* (v1.0.0). jesusarielgb-works. https://github.com/jesusarielgb-works/mobile-governance-framework

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — Jesus Ariel Gonzalez Bonilla. See [LICENSE](LICENSE).
