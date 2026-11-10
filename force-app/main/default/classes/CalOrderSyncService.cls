public with sharing class CalOrderSyncService {
    public static final Integer MAX_ATTEMPTS = 1;

    public class Result {
        public String status;
        public Integer attempts;
    }

    public static Result sendOrder(String payload) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://erp.demo.example/orders');
        request.setMethod('POST');
        request.setBody(payload);
        HttpResponse response = new Http().send(request);
        Result result = new Result();
        result.attempts = 1;
        result.status = response.getStatusCode() == 200 ? 'SENT' : 'FAILED';
        return result;
    }

    public static void sendOrderLater(String payload) {
        sendOrder(payload);
    }
}