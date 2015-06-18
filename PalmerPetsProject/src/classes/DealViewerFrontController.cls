public class DealViewerFrontController {
	public String contactId = ApexPages.currentPage().getParameters().get('contactId');
    public Contact contact;
    public List<DisplayOffers> dealsList;
    public static Map<String, String> dealActionMap = new Map<String, String>();
    
    public List<DisplayOffers> getOffers() {
        if(dealsList==null){
            dealsList = new List<DisplayOffers>();
            for(Deal__c item: [
                //Select action__c, contact__r.name,deal__r.name from deal_action__c
                // old query to get the dealActions and deals join from dealActions object.
                Select Name,(Select Action__c From Deal_Actions__r),Valid_Through__c,Available_Deals__c From Deal__c d
                ])
                {
                    dealsList.add(new DisplayOffers(item));
                }
            for(Deal_Action__c dealAction: [
                Select d.SystemModstamp, d.OwnerId, d.Name,
                d.LastViewedDate, d.LastReferencedDate, d.LastModifiedDate, 
                d.LastModifiedById, d.LastActivityDate, d.IsDeleted, d.Id, 
                d.CreatedDate, d.CreatedById, d.Contact__c, d.Action__c, d.Deal__r.Name 
                From Deal_Action__c d
            	Where d.Contact__r.Id=:contactId
            ])
            	{
                    String dealName = dealAction.Deal__r.Name;
                    dealActionMap.put(dealName, dealAction.Action__c);
                }
            
            
        }
        return dealsList;
    }

    
    public class DisplayOffers{
        private Deal__c deal;
        
        public DisplayOffers(Deal__c item){
                this.deal = item;    
        }

        public String status
        { 
            get{ 
                if(dealActionMap.containsKey(deal.Name)){
                    //Deal_Action__c dealAction = (Deal_Action__c)dealActionMap.get(deal.Name);
                    //return dealAction.Action__c;
                    return dealActionMap.get(deal.Name);
                }
                else
                {
                    //Deal_Action__c da = (Deal_Action__c)dealActionMap.get(deal.Name);
            		//return da.Action__c;
                    return 'Available';
                }
            }
            
        }
        public String icon{
            get { return 'defaultIcon';}
        }
        public String dealName
        {
            get{ return deal.name; }
        }
        public Date validThrough
        {
            get{ return deal.Valid_Through__c; }
        }
        public Decimal availableDeals{
            get { return deal.available_deals__c; }
        }
        
    }
}