public with sharing class Util {
    public static BullhornEntity getInstance(String destination) {
        switch on destination {
            when 'Account', 'ClientCorporation' {
                return new ClientCorporationEntity();
            }
            when 'Contact', 'ClientContact' {
                return new ClientContactEntity();
            }
            when 'Job', 'Job__c', 'JobOrder' {
                return new JobOrderEntity();
            }
            when 'Candidate' {
                return new CandidateEntity();
            }
         //   when 'Appointment' {
         //       return new AppointmentEntity();
         //   }
            when else {
                System.debug('  ===> No Object Found');
                return null;
            }
        }
        return null;
    }
}