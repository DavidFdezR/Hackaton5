# ARM-X Hackathon

This repository is a **temporary snapshot for the ARM-X Hackathon**.

**It will be deleted after November 15, 2026.** Do not treat it as a long-lived project.

The metadata was retrieved on November 10, 2026 from the Salesforce scratch org alias `Hackaton3` (org name **Hackathon QA**, username `test-klohffq5rxub@example.com`, API 68.0). No packages were installed in that org.

## What was retrieved

`manifest/package.xml` is the manifest that retrieved successfully (993 components, source in `force-app/`). It combines two catalogs:

1. **Metadata API.** Every component `sf project generate manifest --from-org Hackaton3` listed. That unmodified list is `manifest/package-from-org.xml`.
2. **Tooling API.** Components present in the org that the Metadata API list omitted. They were found with Tooling queries (`CustomObject`, `CustomField`, `CustomApplication`, `PermissionSet`, `Layout`, `SourceMember`, and the other metadata objects) and added before retrieve. That is how the custom objects (`CH3_*`, `Demo_*`), Account customizations, apps, tabs, queues, permission sets, validation rules, record types, list views, and the external client app got into the project.

## Present in the org, not retrievable as metadata

These showed up in the Tooling API or in source tracking, and the retrieve API rejected them:

- `GenOpAgentConfig` `Demo_Invoice_Review` — the org returns `Cannot use: GenOpAgentConfig in this organization`. The member is recorded in `manifest/package-tooling-only.xml`. The installed CLI registry also has no definition for that type.
- `DigitalExperienceBundle` `fragment_space/DefaultWidgetSpace` — source tracking lists it, and both list and retrieve return no such component. CMS spaces in the org are empty.
- Tooling `CleanRule` geocode rules, `AccessControlPolicy`, and 65 layouts whose Tooling names are not valid Metadata API full names (`CleanDataService`, `AccessControlPolicy`, and those layouts).
- `UiViewDefinition` is not available in this org. `WorkflowFlowAutomation` members from listMetadata are not valid retrieve names.

## Retrieve again

```bash
sf project retrieve start --manifest manifest/package.xml --target-org Hackaton3
```
