public with sharing class ClientCorporationWrapper {
    public Decimal id ;
    public String name;
    public Association clientCorporation ;
    public String parentClientCorporation;
    public String companyURL;
    public billingAddress address ;
    public String companyDescription;
    public String phone;
    public String Bullhorn_ID;
    public class billingAddress {
        public String countryID ;
        public String city ;
        public String state ;
        public String address2 ;
        public String zip ;
        public String address1 ;
    }

}