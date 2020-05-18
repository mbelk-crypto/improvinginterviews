public class BullhornConnector {

    public static Map<String, object> getAuthorizationCode(String clientId, String ClientSecret, String userName, String password) {
        String authorizationCode = '';
        String apiPass = EncodingUtil.urlEncode(password, 'UTF-8');//TODO API Pass hardCode or CustomLabel

        String endpoint = 'https://auth.bullhornstaffing.com/oauth/authorize?' +
                'client_id=' + clientId + '&response_type=code' +
                '&username=' + userName + '&password=' + apiPass +
                '&action=Login';
        System.debug(endpoint + '  ===> endpoint');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        HttpResponse response = http.send(request);
        System.debug(response + '  ===> response');
        System.debug(response.getBody() + '  ===> response.Body');
        System.debug(response.getStatus() + '  ===> response.getStatus()');
        System.debug(response.getStatusCode() + '  ===> response.getStatusCode()');
        if (response.getStatus() == 'Found' && response.getStatusCode() == 302) {
            system.debug('#---#' + response.getHeaderKeys());
            String redirectURL = EncodingUtil.urlDecode(response.getHeader('Location'), 'UTF-8');
            System.debug('redirectURL: ' + redirectURL);
            Integer startIndex = redirectURL.indexOf('code=');
            Integer endIndex = redirectURL.indexOf('&');
            authorizationCode = redirectURL.substring(startIndex + 5, endIndex);
            System.debug('authorizationCode: ' + authorizationCode);
            Map<String, object> responseMap = getAccessTokenAuthCode(authorizationCode, clientId, ClientSecret);
            return responseMap;
        }
        return null;
    }

    public static Map<String, object> getAccessTokenAuthCode(String authorizationCode, String clientId, String clientSecret) {
        String endpoint = 'https://auth.bullhornstaffing.com/oauth/token?grant_type=authorization_code' +
                '&code=' + authorizationCode + '&client_id=' + clientId +
                '&client_secret=' + clientSecret;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        HttpResponse response = http.send(request);
        System.debug(response.getBody() + '  ===> response.getBody()');
        if (response.getStatus() == 'OK' && response.getStatusCode() == 200) {
            Map<String, object> responseMap = (Map<String, object>) JSON.deserializeUntyped(response.getBody()) ;
            String accessToken = String.valueOf(responseMap.get('access_token'));
            System.debug('access_token :' + accessToken);
            String refreshToken = String.valueOf(responseMap.get('refresh_token'));
            System.debug(refreshToken + '  ===> refreshToken');
            Map<String, object> responseMap1 = loginToAPI(accessToken);
            if (responseMap1 != null && !responseMap1.isEmpty())
                responseMap1.put('refresh_token', refreshToken);
            return responseMap1;

        }
        return null;
    }


    public static Map<String, object> getAccessTokenRefreshToken(String refreshToken, String clientId, String clientSecret) {
        //Bullhorn_Authorize__c bullhorn_authorize = Bullhorn_Authorize__c.getInstance(UserInfo.getUserId());
        // System.debug(bullhorn_authorize + '  ===> bullhorn_authorize');
        String endpoint = 'https://auth.bullhornstaffing.com/oauth/token?grant_type=refresh_token' +
                '&refresh_token=' + refreshToken +
                '&client_id=' + clientId +
                '&client_secret=' + clientSecret ;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        HttpResponse response = http.send(request);
        System.debug(response.getBody() + '  ===> response.getBody()');

        if (response.getStatus() == 'OK' && response.getStatusCode() == 200) {
            Map<String, object> responseMap = (Map<String, object>) JSON.deserializeUntyped(response.getBody()) ;
            String accessToken = String.valueOf(responseMap.get('access_token'));
            String newRefreshToken = String.valueOf(responseMap.get('refresh_token'));
            System.debug('access_token :' + accessToken);
            Map<String, object> responseMap1 = loginToAPI(accessToken);
            if (responseMap1 != null && !responseMap1.isEmpty())
                responseMap1.put('refresh_token', newRefreshToken);
            return responseMap1;
        }
        return null;
    }

    public static Map<String, object> loginToAPI(String accessToken) {
        String endpoint = 'https://rest.bullhornstaffing.com/rest-services/login?version=*&access_token=' + accessToken;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        HttpResponse response = http.send(request);
        System.debug('response: ' + response);
        Map<String, object> responseMap;
        System.debug(response.getBody() + '  ===> response.getBody()');

        if (response.getStatus() == 'OK' && response.getStatusCode() == 200) {
            responseMap = (Map<String, object>) JSON.deserializeUntyped(response.getBody()) ;
            String BhRestToken = String.valueOf(responseMap.get('BhRestToken'));
            System.debug('BhRestToken :' + BhRestToken);
            String restUrl = String.valueOf(responseMap.get('restUrl'));
            System.debug('restUrl :' + restUrl);
            return responseMap;
        }
        return null;
    }


    public static List<Object> getChangesFromBullHorn(String restUrl,
            BullhornEntity bullhornEntityType, String BhRestToken,
            String start, String whereJSON) {

        String endPoint = restUrl + 'query' + '/' + bullhornEntityType.getEntityName() +
                '?BhRestToken=' + BhRestToken + '&fields=*' +
                '&start=' + start +
                '&count=' + Label.QueryCount;
        Integer responseCount = 0; // initial count (if count is change to more than 0 then only the process is proceeded)
        System.debug(endPoint + '  ===> endPoint');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(whereJSON);
        request.setTimeout(60000);
        HttpResponse response = new HttpResponse();
        Integer flag = 0;
        while (flag < 2) {

            try {
                response = http.send(request);
                break;
            } catch (CalloutException e) {
                System.debug('Exception: ' + e + ', Message: ' + e.getMessage() + ', Line Number: ' + e.getLineNumber() + '\n' + e.getStackTraceString());
                if (e.getMessage().contains('Read timed out')) {
                    flag++;
                } else {
                    break;
                }
            } catch (Exception e) {
                System.debug('Message: ' + e.getMessage() + ', Line Number: ' + e.getLineNumber() + '\n' + e.getStackTraceString());
                break;
            }
        }

        System.debug(response.getBody() + '  ===> response.getBody()');
        List<Object> objectList = new List<Object>();
        if (response.getStatus() == 'OK' && response.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            responseCount = Integer.valueOf(responseMap.get('count'));
            System.debug('count :' + responseCount);
            if (responseCount > 0) {
                objectList = bullhornEntityType.deserialiseToWrapper(responseMap);
            }
        }
        return objectList;
    }

    public static List<Object> getJobsFromBullHorn(String restUrl,
            BullhornEntity bullhornEntityType, String BhRestToken,
            String start, String whereJSON) {

        String endPoint = restUrl + 'query' + '/' + bullhornEntityType.getEntityName() +
                '?BhRestToken=' + BhRestToken + '&fields=*' +
                '&start=' + start +
                '&count=500';
        Integer responseCount = 0; // initial count (if count is change to more than 0 then only the process is proceeded)
        System.debug(endPoint + '  ===> endPoint');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(whereJSON);
        request.setTimeout(60000);
        HttpResponse response = new HttpResponse();
        Integer flag = 0;
        while (flag < 2) {

            try {
                response = http.send(request);
                break;
            } catch (CalloutException e) {
                System.debug('Exception: ' + e + ', Message: ' + e.getMessage() + ', Line Number: ' + e.getLineNumber() + '\n' + e.getStackTraceString());
                if (e.getMessage().contains('Read timed out')) {
                    flag++;
                } else {
                    break;
                }
            } catch (Exception e) {
                System.debug('Message: ' + e.getMessage() + ', Line Number: ' + e.getLineNumber() + '\n' + e.getStackTraceString());
                break;
            }
        }

        System.debug(response.getBody() + '  ===> response.getBody()');
        List<Object> objectList = new List<Object>();
        if (response.getStatus() == 'OK' && response.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            responseCount = Integer.valueOf(responseMap.get('count'));
            System.debug('count :' + responseCount);
            if (responseCount > 0) {
                objectList = bullhornEntityType.deserialiseToWrapper(responseMap);
            }
        }
        return objectList;
    }

    public static List<Object> getCandidateChangesFromBullHorn(String restUrl,
            BullhornEntity bullhornEntityType, String BhRestToken,
            String start, String whereJSON) {

        String endPoint = restUrl + 'search' + '/' + bullhornEntityType.getEntityName() +
                '?BhRestToken=' + BhRestToken + '&fields=id,firstName,lastName,phone,email,dateLastModified' +
                '&start=' + start +
                '&count=' + Label.QueryCount;
        Integer responseCount = 0; // initial count (if count is change to more than 0 then only the process is proceeded)
        System.debug(endPoint + '  ===> endPoint');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(whereJSON);
        HttpResponse response;
        Integer flag = 0;
        while (flag < 2) {

            try {
                response = http.send(request);
                break;
            } catch (CalloutException e) {
                System.debug('Exception: ' + e + ', Message: ' + e.getMessage() + ', Line Number: ' + e.getLineNumber() + '\n' + e.getStackTraceString());
                if (e.getMessage().contains('Read timed out')) {
                    flag++;
                } else {
                    break;
                }
            } catch (Exception e) {
                System.debug('Message: ' + e.getMessage() + ', Line Number: ' + e.getLineNumber() + '\n' + e.getStackTraceString());
                break;
            }
        }
                
        System.debug(response.getBody() + '  ===> response.getBody()');
        List<Object> objectList = new List<Object>();
        if (response.getStatus() == 'OK' && response.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            responseCount = Integer.valueOf(responseMap.get('count'));
            System.debug('count :' + responseCount);
            if (responseCount > 0) {
                objectList = bullhornEntityType.deserialiseToWrapper(responseMap);
            }
        }
        return objectList;
    }
 
}