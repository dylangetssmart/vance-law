select distinct
	kind
from VanceLawFirm_Needles..negotiation n
where
	ISNULL(kind, '') <> ''
order by n.kind