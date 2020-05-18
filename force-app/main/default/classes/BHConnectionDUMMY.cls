public class BHConnectionDUMMY {
    public BHConnectionDUMMY() {
    }
    //https://auth.bullhornstaffing.com/oauth/authorize?client_id=47bd15cd-9f2a-4423-9dd0-68c409e33055&response_type=code&state=12345&username=3ci.salesforce.api&password=cloudhappy12!&action=Login
    public static Map<String, object> getAuthorizationCode() {
        String authorizationCode = '';
        String apiPass = EncodingUtil.urlEncode('%H~UR^qYqp$7UXb_', 'UTF-8');

        String endpoint = 'https://auth.bullhornstaffing.com/oauth/authorize?' +
                'client_id=29806102-13d6-4790-9ddd-56ead8f65498&response_type=code' +
                '&username=improvinginterviews.api&password=' + apiPass+
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
            system.debug('#---#'+response.getHeaderKeys());
            String redirectURL = EncodingUtil.urlDecode(response.getHeader('Location'), 'UTF-8');
            System.debug('redirectURL: ' + redirectURL);
            Integer startIndex = redirectURL.indexOf('code=');
            Integer endIndex = redirectURL.indexOf('&');
            authorizationCode = redirectURL.substring(startIndex + 5, endIndex);
            System.debug('authorizationCode: ' + authorizationCode);
            Map<String, object> responseMap = getAccessToken(authorizationCode);
            return responseMap;
        }
        return null;
    }

    public static Map<String, object> getAccessToken(String authorizationCode) {
        String endpoint = 'https://auth.bullhornstaffing.com/oauth/token?grant_type=authorization_code&' +
                'code=' + authorizationCode + '&client_id=29806102-13d6-4790-9ddd-56ead8f65498&' +
                'client_secret=8MVAREG19BdVIxDvKKIUiE1n';
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


    public static String createNewEntity(String entityName, String jsonBody, String BhRestToken, String restUrl) {
        System.debug('BhRestToken: ' + BhRestToken);
        System.debug('restUrl: ' + restUrl);
        String changedEntityId = '';
        String endpoint = restUrl + '/entity/' + entityName + '?BhRestToken=' + BhRestToken + '&fields=*';
        System.debug('endpoint: ' + endpoint);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('PUT');
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(jsonBody);
        HttpResponse response = http.send(request);
        System.debug('response: ' + response);
        System.debug('response body: ' + response.getBody());
        if (response.getStatus() == 'OK' && response.getStatusCode() == 200) {
            Map<String, object> responseMap = (Map<String, object>) JSON.deserializeUntyped(response.getBody()) ;
            changedEntityId = String.valueOf(responseMap.get('changedEntityId'));
            System.debug('changedEntityId :' + changedEntityId);
        }
        return changedEntityId;
    }
}