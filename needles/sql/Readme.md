# Needles Readme

**Script Prefixes**
- std = standard script
- user = custom for client, related to user mapping
- value = related to value codes

# `\init`

Initialize the Needles database with helper tables and functions.

# `\map`

Query several Needles tables to create field mapping spreadsheet.

# `\conv`

## helpers

Initialize the SA database with helper tables and functions.

Script|Purpose|Notes
:---|:---|:---
0.00_Initialize.SQL|Creates various functions to extract and massage data|
0.10_CaseTypeMixture.SQL|Creates table CaseTypeMixture used to cross reference Caes Types|Harcoded for initial conversion
0.20_CaseValueMapping.sql|Creates table CaseValueMapping and populates it with default values|
0.30_ImplementationUsersMap.sql|Creates table implementation_users and populates it with users from `[dbo].[staff]`|Optionally, seed the table with user records from the implementation database
0.40_NeedlesUserFields.sql|Creates table NeedlesUserFields|
0.50_PartyRole.sql|Creates table PartyRoles used to cross reference party roles|Harcoded for initial conversion

## contact
Script|Target|Source|Dependency
:---|:---|:---|:---
1.00_std_UnidentifiedIndvContacts.sql|`[sma_MST_IndvContacts]`|hardcode
1.01_std_UnidentifiedOrgContacts.sql|`[sma_MST_OrgContacts]`|hardcode
1.02_std_Contacts.sql|`[sma_MST_IndvContacts]`, `[sma_MST_Users]`|
1.03_std_insured.sql|`[sma_MST_IndvContacts]`|`[needles]..[insurance]`|
1.04_std_police.sql|`[sma_MST_IndvContacts]`|`[needles]..[police]`|
1.10_std_email.sql|`[sma_MST_EmailWebsite]`|
1.11_std_phone.SQL|`[sma_MST_ContactNumbers]`|`[needles]..[names]`
1.40_std_Address.SQL|`[sma_MST_Address]`|`[needles]..[multi_addresses]`|`[sma_MST_IndvContacts]`,`[sma_MST_OrgContacts]`
1.89_std_Uniqueness.sql||
1.90_std_AllContactInfo.sql|`[sma_MST_AllContactInfo]`|`[sma_MST_IndvContacts]`,`[sma_MST_Address]`,`[sma_MST_ContactNumbers]`,`[sma_MST_EmailWebsite]`
1.91_std_Comment.SQL||
1.91_std_IndvOrgContacts.sql|`[sma_MST_IndvOrg_Indexed]`|`[sma_MST_AllContactInfo]`|
1.92_std_Notes.SQL|`[sma_TRN_Notes]`|`[needles]..[provider_notes]`, `[needles]..[party]`

## case
Script|Target|Source
:---|:---|:---
2.00_std_CaseType.SQL|`[sma_MST_CaseGroup]`,`[sma_MST_offices]`,`[sma_MST_CaseType]`,`[sma_MST_CaseSubTypeCode]`,`[sma_MST_CaseSubType]`,`[sma_MST_CaseSubType]`,`[sma_MST_SubRole]`,`[sma_MST_SubRoleCode]`,`[sma_TRN_Cases]`|
2.01_std_CaseValue.sql|`[sma_TRN_CaseValue]`|`[needles]..[insurance_Indexed]`
2.02_std_CaseStaff.sql|`[sma_TRN_CaseStaff]`|`[needles]..[cases_Indexed]`
2.03_std_CaseStatus.sql|`[sma_MST_CaseStatus]`,`[sma_TRN_CaseStatus]`|`[needles]..[cases_Indexed]`
2.05_std_CalendarNonCase.sql|`[]`|
2.05_std_Plaintiff_Defendant.sql|`[]`|
2.06_std_Insurance.sql|`[]`|
2.07_std_Court.sql|`[]`|
2.08_std_Decedent.sql|`[]`|
2.09_std_Defendant_Attorney.sql|`[]`|
2.10_std_PoliceReport.sql|`[]`|
2.11_std_CriticalComments.sql|`[]`|
2.12_std_CriticalDeadLines.sql|`[]`|
2.13_std_Negotiate.sql|`[]`|
2.14_std_SOL.sql|`[]`|
2.15_std_ReferOut.sql|`[]`|
2.16_std_OtherReferral.sql|`[]`|
2.17_std_Notes.sql|`[]`|
2.18_std_SOLChecklist.sql|`[]`|
2.19_std_Calendar.sql|`[]`|
2.20_std_Incident.sql|`[]`|
2.30_user_AllContacts.sql|`[]`|
2.31_user_CaseStatus.sql|`[]`|
2.32_user_CaseValues.sql|`[]`|
2.33_user_CaseType.sql|`[]`|
2.34_user_Disbursement.sql||
2.35_user_MedicalRecord.SQL||
2.36_user_Employment.sql||
2.37_user_School.sql||
2.38_user_PriorInjury.sql||
2.39_user_Injury.sql||
2.40_user_Investigations-Witness.sql||
2.41_user_Settlements.sql||
2.42_user_Plaintiff_SpDamages.sql||
2.43_user_Negotiation.sql||
2.50_value_Notes.sql||
2.51_value_LienTracking.sql||
2.52_value_Settlements.sql||
2.53_value_SpecialDamages.sql||
2.54_value_MedicalProviders.sql||
2.55_value_Disbursement.sql||
2.56_value_Employment.sql||

## UDF

## Misc

## Intake
