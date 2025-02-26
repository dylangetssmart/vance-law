SELECT
	*
FROM mailing_address ma
WHERE ma.[primary] IS NOT NULL

SELECT
	lb.name AS EmailType
   ,e.first_name
   ,ma.*
FROM mailing_address ma
JOIN lookup_bucket lb
	ON ma.mailing_address_type_id = lb.id
JOIN entity e
	ON ma.entity_id = e.id

SELECT DISTINCT
	lb.name
FROM mailing_address ma
JOIN lookup_bucket lb
	ON lb.id = ma.mailing_address_type_id

--Business
--Home
--Other

USE JoelBieberSA_GP

-- Home from IndvContacts
INSERT INTO [sma_MST_Address]
	(
	[addnContactCtgID]
   ,[addnContactID]
   ,[addnAddressTypeID]
   ,[addsAddressType]
   ,[addsAddTypeCode]
   ,[addsAddress1]
   ,[addsAddress2]
   ,[addsAddress3]
   ,[addsStateCode]
   ,[addsCity]
   ,[addnZipID]
   ,[addsZip]
   ,[addsCounty]
   ,[addsCountry]
   ,[addbIsResidence]
   ,[addbPrimary]
   ,[adddFromDate]
   ,[adddToDate]
   ,[addnCompanyID]
   ,[addsDepartment]
   ,[addsTitle]
   ,[addnContactPersonID]
   ,[addsComments]
   ,[addbIsCurrent]
   ,[addbIsMailing]
   ,[addnRecUserID]
   ,[adddDtCreated]
   ,[addnModifyUserID]
   ,[adddDtModified]
   ,[addnLevelNo]
   ,[caseno]
   ,[addbDeleted]
   ,[addsZipExtn]
   ,[saga]
	)
	SELECT
		I.cinnContactCtg  AS addnContactCtgID
	   ,I.cinnContactID	  AS addnContactID
	   ,CASE lb.name
			WHEN 'Home'
				THEN (
						SELECT
							addnAddTypeID
						FROM sma_mst_addresstypes
						WHERE addsCode = 'HM'
							AND addnContactCategoryID = 1
					)
			WHEN 'Business'
				THEN (
						SELECT
							addnAddTypeID
						FROM sma_mst_addresstypes
						WHERE addsCode = 'WORK'
							AND addnContactCategoryID = 1
					)
			WHEN 'Other'
				THEN (
						SELECT
							addnAddTypeID
						FROM sma_mst_addresstypes
						WHERE addsCode = 'OTH'
							AND addnContactCategoryID = 1
					)
		END				  AS addnAddressTypeID
	   ,CASE lb.name
			WHEN 'Home'
				THEN (
						SELECT
							addsDscrptn
						FROM sma_mst_addresstypes
						WHERE addsCode = 'HM'
							AND addnContactCategoryID = 1
					)
			WHEN 'Business'
				THEN (
						SELECT
							addsDscrptn
						FROM sma_mst_addresstypes
						WHERE addsCode = 'WORK'
							AND addnContactCategoryID = 1
					)
			WHEN 'Other'
				THEN (
						SELECT
							addsDscrptn
						FROM sma_mst_addresstypes
						WHERE addsCode = 'OTH'
							AND addnContactCategoryID = 1
					)
		END				  AS addnAddressType
	   ,CASE lb.name
			WHEN 'Home'
				THEN 'HM'
			WHEN 'Business'
				THEN 'WORK'
			WHEN 'Other'
				THEN 'OTH'
		END				  AS addsAddTypeCode
	   ,ma.street_address AS addsAddress1
	   ,NULL			  AS addsAddress2
	   ,NULL			  AS addsAddress3
	   ,ma.state		  AS addsStateCode
	   ,ma.city			  AS addsCity
	   ,NULL			  AS addnZipID
	   ,ma.zip			  AS addsZip
	   ,NULL			  AS addsCounty
	   ,NULL			  AS addsCountry
	   ,NULL			  AS addbIsResidence
	   ,CASE
			WHEN ma.[primary] = 't'
				THEN 1
			ELSE 0
		END				  AS addbPrimary
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,ma.extra_info	  AS [addsComments]
	   ,NULL
	   ,NULL
	   ,368				  AS addnRecUserID
	   ,GETDATE()		  AS adddDtCreated
	   ,368				  AS addnModifyUserID
	   ,GETDATE()		  AS adddDtModified
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	FROM JoelBieber_GrowPath..mailing_address ma
	JOIN JoelBieber_GrowPath..lookup_bucket lb
		ON lb.id = ma.mailing_address_type_id
	JOIN JoelBieber_GrowPath..entity e
		ON e.id = ma.entity_id
	JOIN [sma_MST_Indvcontacts] i
		ON i.saga = e.id

--FROM [JoelBieberNeedles].[dbo].[multi_addresses] A
--JOIN [sma_MST_AddressTypes] T on T.addnContactCategoryID = I.cinnContactCtg and T.addsCode='HM'
--WHERE (A.[addr_type]='Home' and ( isnull(A.[address],'')<>'' or isnull(A.[address_2],'')<>'' or isnull( A.[city],'')<>'' or isnull(A.[state],'')<>'' or isnull(A.[zipcode],'')<>'' or isnull(A.[county],'')<>'' or isnull(A.[country],'')<>''))   