public class DealViewerFrontController {

    public Contact contactperson { get; set; }

    public static String contactId = ApexPages.currentPage().getParameters().get('contactId');
    public List<DisplayOffers> dealsList;
    public static Integer currentPage=1;
    public static Map<String, String> dealActionMap = getDealActions();
    
    public static Map<String,String> getDealActions(){
        Map<String, String> dealActionListMap = new Map<String,String>();
        for(Deal_Action__c dealAction: [
                Select d.SystemModstamp, d.OwnerId, d.Name,
                d.LastViewedDate, d.LastReferencedDate, d.LastModifiedDate, 
                d.LastModifiedById, d.LastActivityDate, d.IsDeleted, d.Id, 
                d.CreatedDate, d.CreatedById, d.Contact__c, d.Action__c, d.Deal__r.Name 
                From Deal_Action__c d
                Where d.Contact__r.Id=:contactId
            ])
                {
                    //dealActionListMap  = new Map<String, String>();
                    String dealName = dealAction.Deal__r.Name;
                    dealActionListMap.put(dealName, dealAction.Action__c);
                }
           return dealActionListMap;
    }

    public Contact getContact(){
        return [Select c.Title, c.SystemModstamp, c.Salutation, c.ReportsToId, c.PhotoUrl, c.Phone, c.OwnerId, c.OtherStreet, c.OtherState, c.OtherPostalCode, c.OtherPhone, c.OtherLongitude, c.OtherLatitude, c.OtherCountry, c.OtherCity, c.OtherAddress, c.Name, c.MobilePhone, c.MasterRecordId, c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingLongitude, c.MailingLatitude, c.MailingCountry, c.MailingCity, c.MailingAddress, c.LeadSource, c.LastViewedDate, c.LastReferencedDate, c.LastName, c.LastModifiedDate, c.LastModifiedById, c.LastCUUpdateDate, c.LastCURequestDate, c.LastActivityDate, c.JigsawContactId, c.Jigsaw, c.IsEmailBounced, c.IsDeleted, c.Id, c.HomePhone, c.FirstName, c.Fax, c.EmailBouncedReason, c.EmailBouncedDate, c.Email, c.Description, c.Department, c.Deals_Rejected__c, c.Deals_Accepted__c, c.CreatedDate, c.CreatedById, c.CleanStatus, c.Birthdate, c.AssistantPhone, c.AssistantName, c.AccountId, c.Acceptance_Rate__c From Contact c where c.Id=:contactId];
    }
    
    public List<DisplayOffers> getOffers() {
        System.debug('Entered getOffers function');
        contactperson = getContact();        
        //if(dealsList==null){
            dealsList = new List<DisplayOffers>();
        //}
/*            for(Deal__c item: [
                //Select action__c, contact__r.name,deal__r.name from deal_action__c
                // old query to get the dealActions and deals join from dealActions object.
                Select Name,(Select Action__c From Deal_Actions__r),Valid_Through__c,Available_Deals__c From Deal__c d Limit :PageSize
                ])
                {
                    dealsList.add(new DisplayOffers(item));
                }
*/
                        List<Deal__c> items = samplePagination.getRecords();
            System.debug('Got records from samplePagination object');
            for(Deal__c item : items){
                dealsList.add(new DisplayOffers(item));
            }
        
        
                //List<Deal__c> items = samplePagination.getRecords();
                System.debug('Got records from samplePagination object outside if condition');
        dealActionMap = new Map<String,String>();
                dealActionMap = getDealActions();

        return dealsList;
    }

    public void rejectOffer() {
        String dealName = ApexPages.currentPage().getParameters().get('dealName');
        Deal__c offerInstance = [Select d.Valid_Through__c, d.SystemModstamp, d.Rejections__c, d.OwnerId, d.Name, d.Max_Acceptances__c, d.LastViewedDate, d.LastReferencedDate, d.LastModifiedDate, d.LastModifiedById, d.LastActivityDate, d.IsDeleted, d.Id, d.CreatedDate, d.CreatedById, d.Available_Deals__c, d.Acceptances__c, d.Acceptance_Rate__c From Deal__c d where d.Name=:dealName];
        Id dealId = offerInstance.Id;
        //Insert a new record for rejected offer instance in the Deal_Action table.
        Deal_Action__c dealAction = new Deal_Action__c(Action__c='Reject', Contact__c=contactId, Deal__c=dealId);
        upsert dealAction;
        
        //Update the offer's rejection count
        offerInstance.Rejections__c+=1;
        update offerInstance;
        
        //update the contact's rejection count
        System.debug(contactperson);
        if(contactperson.Deals_Rejected__c==null)
            contactperson.Deals_Rejected__c=0;
        contactperson.Deals_Rejected__c+=1;
        update contactperson;
    }


    public void acceptOffer() {
        String dealName = ApexPages.currentPage().getParameters().get('dealName');
        Deal__c offerInstance = [Select d.Valid_Through__c, d.SystemModstamp, d.Rejections__c, d.OwnerId, d.Name, d.Max_Acceptances__c, d.LastViewedDate, d.LastReferencedDate, d.LastModifiedDate, d.LastModifiedById, d.LastActivityDate, d.IsDeleted, d.Id, d.CreatedDate, d.CreatedById, d.Available_Deals__c, d.Acceptances__c, d.Acceptance_Rate__c From Deal__c d where d.Name=:dealName];
        Id dealId = offerInstance.Id;
        //Insert a new record for accepted offer instance in the Deal_Action table.
        Deal_Action__c dealAction = new Deal_Action__c(Action__c='Accept', Contact__c=contactId, Deal__c=dealId);
        upsert dealAction;
        
        //Update the offer's acceptances count
        offerInstance.Acceptances__c+=1;
        update offerInstance;
        
        //update the contact's acceptance count
        System.debug(contactperson);
        if(contactperson.Deals_Accepted__c==null)
            contactperson.Deals_Accepted__c=0;
        contactperson.Deals_Accepted__c+=1;
        update contactperson;
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
                    return dealActionMap.get(deal.Name) + 'ed';
                }
                else if (deal.Available_Deals__c > 0)
                {
                    return 'Available';
                }
                else 
                {
                    return 'Not Available';
                }
            }
        }
        
        public String icon{
            
            get 
            { 
                // Fetching the resource
                List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :deal.Name];

                // Checking if the result is returned or not
                if(resourceList.size() == 1){

                // Getting namespace
                String namespace = resourceList[0].NamespacePrefix;
                // Resource URL
                return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + deal.Name; 
                }
                else
                {
                    return '/resource/1435001971000/default';
                }
            }
        }
        
        public String dealName
        {
            get{ return deal.Name; }
        }
        
        public Date validThrough
        {
            get{ return deal.Valid_Through__c; }
        }
        
        public Decimal availableDeals{
            get { return deal.Available_Deals__c; }
        }
        
        public Boolean isRejectable
        {
            get
            { 
                if(dealActionMap.get(deal.Name)==null || deal.Available_Deals__c <= 0)
                    return false;
                else
                    return true;
            }
        }
        
        public Boolean isAcceptable
        {
            get
            { 
                if(dealActionMap.get(deal.Name)==null || deal.Available_Deals__c <= 0)
                    return false;
                else
                    return true;
            }
        }
    }
    
    public Integer PageSize{
        get{ 
            System.debug('getting PageSize');
            return 5; 
        }
        set;
    }
    
    public Integer currentPageOffset{
        get {
            if (currentPage==null)
                currentPage=1;
            return 1;
        }
        set;
    }
    
    public ApexPages.StandardSetController samplePagination{
                get {
                        
            if(samplePagination== null) {
                samplePagination= new ApexPages.StandardSetController(Database.getQueryLocator([
                    Select Name,(Select Action__c From Deal_Actions__r),Valid_Through__c,Available_Deals__c 
                    From Deal__c d 
                    WHERE (d.Available_Deals__c > 0) 
                    AND (d.Valid_Through__c>Today)
                        ORDER by d.Valid_Through__c, d.Available_Deals__c, d.Name]));
                //set number of records you want to show on UI
                samplePagination.setPageSize(PageSize);
            }
            return samplePagination;
            }
        set;
    }    
    
    // indicates whether there are more records after the current page set.
    public Boolean HasNext {
        get {
            return samplePagination.getHasNext();
        }
        set;
    }
 
    // indicates whether there are more records before the current page set.
    public Boolean HasPrevious {
        get {
            return samplePagination.getHasPrevious();
        }
        set;
    }
    
    public void first(){
        System.debug('First method');
        samplePagination.first();
    }
    
    public void last(){    
        System.debug('Last method');
        samplePagination.last();
    }
    
    public void previous()
        {
        System.debug('prev method');
        samplePagination.previous();
    }
 
    public void next()
    {
        System.debug('next method');
        samplePagination.next();
    }
    
    public Integer getResultSize(){
        return samplePagination.getResultSize();
    }
 
    public Integer getPageNumber(){
        return samplePagination.getPageNumber();
    }
    
    public Integer getPageSize(){
        return samplePagination.getPageSize();
    }
    
    public Integer getTotalPages(){
        Integer pageSize = getPageSize();
        Integer resultSize = getResultSize();
        Integer totalPages = resultSize/pageSize + 1;
        System.debug('pageSize = ' + pageSize);
        System.debug('resultSize = ' + resultSize);
        System.debug('totalPages = ' + totalPages);
        return totalPages;
    }
}