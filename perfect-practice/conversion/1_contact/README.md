# Perfect_Practice Conversion 1_Contact

| Script Name | Description | Dependencies |
|-------------|-------------|-------------|
| 1.00_std_UnidentifiedIndvContacts.sql | Create placeholder individual contacts used as fallback when contact records do not exist | [None] |
| 1.01_std_UnidentifiedOrgContacts.sql | Create placeholder organization contacts used as fallback when contact records do not exist | [None] |
| 1.02_std_Contacts.sql | No metadata found | No metadata found |
| 1.03_std_Users.sql | No metadata found | No metadata found |
| 1.04_std_Insured.sql | Create contacts from needles..insurance | [None] |
| 1.05_std_PoliceOfficer.sql | Create police officer contacts from needles..police | [None] |
| 1.90_std_EmailWebsite.sql | update contact email addresses | [None] |
| 1.91_std_PhoneNumbers.sql | Update contact phone numbers | [None] |
| 1.92_std_Address.sql | Insert addresses | [None] |
| 1.94_std_Uniqueness.sql | Ensures the uniqueness of phone numbers in the [sma_MST_ContactNumbers] table | [None] |
| 1.95_std_Comment.sql | None | [None] |
| 1.97_std_AllContactInfo.sql | Create sma_MST_AllContactInfo | [['sma_MST_AllContactInfo'], ['sma_MST_IndvContacts'], ['sma_MST_Address'], ['sma_MST_ContactNumbers'], ['sma_MST_EmailWebsite']] |
| 1.98_std_IndvOrgContacts_Indexed.sql | None | ['sma_MST_AllContactInfo'] |
| 1.99_std_Notes.sql | No metadata found | No metadata found |
| Step_1.0_Contacts.sql | No metadata found | No metadata found |
| Step_1.1_Contacts_Supplement.sql | No metadata found | No metadata found |
| Step_2.0_Supporting_Default_Contacts.sql | No metadata found | No metadata found |
| Step_2.3_Supporting_Court_Contact.SQL | No metadata found | No metadata found |
| Step_2.4_Supporting_Default_Insurance.SQL | No metadata found | No metadata found |
| Step_2.6_Supporting_Adjustor_Insurance.SQL | No metadata found | No metadata found |
| Step_2.7_Supporting_ReferringSource_Contacts.SQL | No metadata found | No metadata found |
| Step_2.8_Supporting_Judge_Contacts.sql | No metadata found | No metadata found |
| Step_4.0_Address.SQL | No metadata found | No metadata found |
| Step_4.1_EmailWebsite.SQL | No metadata found | No metadata found |
| Step_4.2_ContactNumber.SQL | No metadata found | No metadata found |
| Step_4.3_StaffPhoneEmail.SQL | No metadata found | No metadata found |
| Step_4.5_Uniqueness.SQL | No metadata found | No metadata found |
| Step_5.0_AllContactInfo.SQL | No metadata found | No metadata found |
| Step_5.1_IndvOrgContacts.SQL | No metadata found | No metadata found |
