echo %time%

REM ----------------osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_0.0_CaseTypeMixture.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_0.0_CaseValueMapping.SQL

osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_0.1_Initialize.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_0.9_Implementation_Users.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_1.0_Contacts.sql
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_1.1_Contacts_Supplement.sql
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_2.0_Supporting_Default_Contacts.sql
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_2.3_Supporting_Court_Contact.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_2.4_Supporting_Default_Insurance.SQL
REM ----------------osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_2.5_Supporting_PdAdvt_Contacts.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_2.6_Supporting_Adjustor_Insurance.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_2.7_Supporting_ReferringSource_Contacts.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_2.8_Supporting_Judge_Contacts.sql

osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_4.0_Address.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_4.1_EmailWebsite.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_4.2_ContactNumber.SQL
REM ----------------osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_4.3_StaffPhoneEmail.SQL

osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_4.5_Uniqueness.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_5.0_AllContactInfo.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_5.1_IndvOrgContacts.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_6.0_CaseType.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_6.2_CaseType_Emroch.SQL

osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_7.0_Incident.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_7.1_CaseStaff.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_7.2_CaseStatus.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_8.0_Plaintiff_Defendant.SQL

osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.1_Insurance.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.2_Attorney.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.3_Court.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.5_SOL.SQL
REM ----------------osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.6_PdAdvt.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.8_SpecialDamage.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.9_LienTraking.SQL

osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.10_OtherRefer.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.11_Expert.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.12_Police.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.13_Injury.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.14_Employer.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.15_Investigator.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.15_Witness.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.16_Settlement.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.17_MedicalProvider.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.18_OtherAllContacts.SQL

osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.19_Other1_Auto_Acc.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.19_Other2_Firstcall.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.19_Other3_ClientPersonal.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.19_Other4_AutoInsurance.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.19_Other5_DefaultAutoIns.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_10.20_QC_CaseUDF.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_11.0_Notes.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_11.1_Calendar.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_11.3_Task.SQL

osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_13.0_ContactTypes.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_13.1_Miscellany.SQL
osql -S SACONVERSION\SQL2022 -d SAPerfectPracticeEmroch -E -i Step_5.0_AllContactInfo.SQL


echo %time%
