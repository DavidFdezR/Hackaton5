# ARM-X Hackathon

This repository is a **temporary snapshot for the ARM-X Hackathon**.

**It will be deleted after November 15, 2026.** Do not treat it as a long-lived project.

The metadata was retrieved on November 10, 2026 from the Salesforce scratch org alias `Hackaton5` (org name **Hackathon QA**, username `test-u4omazi53nnx@example.com`, API 68.0). No packages were installed in that org.

## What was retrieved

`manifest/package.xml` is the manifest that retrieved successfully (1,753 components, source in `force-app/`). It combines two catalogs:

1. **Metadata API.** Every component `sf project generate manifest --from-org Hackaton5` listed. That unmodified list is `manifest/package-from-org.xml`.
2. **Tooling API.** Components present in the org that the Metadata API list omitted. They were found with Tooling queries (`SourceMember`, `CustomObject`, `CustomField`, `CustomApplication`, `Layout`, and the other metadata objects) and added before retrieve. That includes the custom objects, Account and Contact customizations, Apex, Lightning web components, flows, apps, tabs, and permission sets.

## Present in the org, not retrievable as metadata

Source tracking lists these, and the Metadata API rejects them. The names are in `manifest/package-tooling-only.xml`.

- `GenOpAgentConfig` (2 components) — `Cannot use: GenOpAgentConfig in this organization`. The CLI registry has no definition for this type either.
- `TenantSecurityPlaybookDef`, `TenantSecurityStepDef`, and `TenantSecurityStepDefVer` — the org returns the same "cannot use" error.
- `DigitalExperienceBundle` — source tracking lists it, and list and retrieve return no such component.
- `TestAccountDataAccessClass` and `TestDataAccessClass` — listed by source tracking, not returned by retrieve.
- `UiViewDefinition` is not available in this org. `WorkflowFlowAutomation` members from listMetadata are not valid retrieve names. 65 layouts returned by the Tooling API are not valid Metadata API full names.

## Retrieve again

```bash
sf project retrieve start --manifest manifest/package.xml --target-org Hackaton5
```
