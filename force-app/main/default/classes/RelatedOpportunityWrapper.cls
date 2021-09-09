public without sharing class RelatedOpportunityWrapper {
	@AuraEnabled
	public Id idVal { get; set; }
	@AuraEnabled
	public String OppNumber { get; set; }
	@AuraEnabled
	public String OppName { get; set; }
	@AuraEnabled
	public Decimal TotalDealVal { get; set; }
	@AuraEnabled
	public List<RelatedOpportunityWrapper> childRelatedOpportunityWrapper {
		get;
		set;
	}
	@AuraEnabled
	public String OppLink { get; set; }
	@AuraEnabled
	public Date OppCloseDate { get; set; }
	@AuraEnabled
	public String OppStageName { get; set; }
	@AuraEnabled
	public Decimal OppMargin { get; set; }
	@AuraEnabled
	public String RecordTypeName { get; set; }

	public RelatedOpportunityWrapper(
		Id idVal,
		String OppNumber,
		String OppName,
		Decimal TotalDealVal,
		List<RelatedOpportunityWrapper> childRelatedOpportunityWrapper,
		String OppLink,
		Date OppCloseDate,
		String OppStageName,
		Decimal OppMargin,
		String RecordTypeName
	) {
		this.idVal = idVal;
		this.OppNumber = OppNumber;
		this.OppName = OppName;
		this.TotalDealVal = TotalDealVal;
		this.childRelatedOpportunityWrapper = childRelatedOpportunityWrapper;
		this.OppLink = OppLink;
		this.OppCloseDate = OppCloseDate;
		this.OppStageName = OppStageName;
		this.OppMargin = OppMargin;
		this.RecordTypeName = RecordTypeName;
	}
	public RelatedOpportunityWrapper() {
		this.idVal = null;
		this.OppNumber = null;
		this.OppName = null;
		this.TotalDealVal = null;
		this.childRelatedOpportunityWrapper = null;
		this.OppLink = null;
		this.OppCloseDate = null;
		this.OppStageName = null;
		this.OppMargin = null;
		this.RecordTypeName = null;
	}
}