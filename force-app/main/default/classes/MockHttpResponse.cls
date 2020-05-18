@isTest
public class MockHttpResponse implements HttpCalloutMock{
    //BhRestToken -   2c5e5d9a-1a9f-49de-a391-f4491dae87f0
    //restUrl -       https://rest30.bullhornstaffing.com/rest-services/2zxg00/

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();

        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setStatus('OK');

        //for getAccessToken
        if (req.getMethod() == 'POST' && req.getEndpoint().contains('oauth/authorize')) {
            System.debug('get oAuth');
            res.setStatus('Found');
            res.setStatusCode(302);
            res.setHeader('Location' , 'https://www.xyz.com?code=asdfcvf&abc=a');
            res.setBody('{  "access_token" : "30:def1c9af-e28f-4f2b-b23a-14b4bc67119a",  "token_type" : "Bearer",  "expires_in" : 600,  "refresh_token" : "30:6828e76a-d7e3-44ef-9d10-db527fd2a827"}');
            return res;
        }
        if (req.getMethod() == 'POST' && req.getEndpoint().contains('grant_type=authorization_code')) {
            System.debug('get Access Token');
            res.setBody('{  "access_token" : "30:def1c9af-e28f-4f2b-b23a-14b4bc67119a",  "token_type" : "Bearer",  "expires_in" : 600,  "refresh_token" : "30:6828e76a-d7e3-44ef-9d10-db527fd2a827"}');
            return res;
        }
        if (req.getMethod() == 'POST' && req.getEndpoint().contains('grant_type=refresh_token')) {
            System.debug('get Access Token');
            res.setBody('{  "access_token" : "30:def1c9af-e28f-4f2b-b23a-14b4bc67119a",  "token_type" : "Bearer",  "expires_in" : 600,  "refresh_token" : "30:6828e76a-d7e3-44ef-9d10-db527fd2a827"}');
            return res;
        }
        if (req.getMethod() == 'POST' && req.getEndpoint().contains('rest-services/login')) {
            System.debug('Login to ApI');
            res.setBody('{"BhRestToken":"2c5e5d9a-1a9f-49de-a391-f4491dae87f0","restUrl":"https://rest30.bullhornstaffing.com/rest-services/2zxg00/"}');
            return res;
        }



        if (req.getEndpoint().contains('entity/')) {
            System.debug('Call to BH ');

            //when the user is inserting
            if (req.getMethod() == 'PUT') {
                System.debug('Inserting');
                res.setBody('{  "changedEntityId": 1489,  "changeType": "INSERT"}');
                return res;
            }
            //when the user is updating
            else if (req.getMethod() == 'POST') {
                System.debug('Updating');
                res.setBody('{  "changedEntityId": 1489,  "changeType": "UPDATE"}');
                return res;
            }
        }

        if(req.getEndpoint().contains('query/')) {
            System.debug(' Changes from Bullhorn');
            res.setBody('{    "start": 0,    "count": 1,    "data": [ { "id": 23, "address": { "address1": "0", "address2": "0", "city": "0", "state": "0", "zip": "0", "countryID": 1, "countryName": "United States", "countryCode": "US" }, "lastName": "testName" } ]}');
            return res;
        }

        if(req.getEndpoint().contains('search/')) {
            System.debug('Candidate Changes from Bullhorn');
            res.setBody('{    "start": 0,    "count": 100,    "data": [' +
                    '{ ' +
                    '"id": 11, ' +
                    '"firstName": "Cloud Happy Test", ' +
                    '"lastName": "Candidate", ' +
                    '"dateLastModified": 1554201210450, "_score": 1 }]}');
            return res;
        }
        return null;
    }
}