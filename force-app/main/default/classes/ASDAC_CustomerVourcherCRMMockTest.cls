public class ASDAC_CustomerVourcherCRMMockTest implements HttpCalloutMock {
    
    public HttpResponse respond(HttpRequest request){
        
        String accesstoken = 'eyJ0eXAiOiJKV1QiLCJraWQiOiJEMWhPUDdEODN4TjBqZWlqaTI3WWFvZFRjL0E9IiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiI5OTg3ZjU4OS02MGQwLTRlODAtYTJhZi0yZTkyNjhkNzdkY2MiLCJjdHMiOiJPQVVUSDJfU1RBVEVMRVNTX0dSQU5UIiwiYXVkaXRUcmFja2luZ0lkIjoiZGJkNmI1MDEtMzc0Mi00ODE4LWEwMDYtYThiMjc2MWJkYjUzLTE2Mzg1MDIzNyIsInN1Ym5hbWUiOiI5OTg3ZjU4OS02MGQwLTRlODAtYTJhZi0yZTkyNjhkNzdkY2MiLCJpc3MiOiJodHRwczovL2FjY291bnQuZGVtYW5kd2FyZS5jb206NDQzL2R3c3NvL29hdXRoMiIsInRva2VuTmFtZSI6ImFjY2Vzc190b2tlbiIsInRva2VuX3R5cGUiOiJCZWFyZXIiLCJhdXRoR3JhbnRJZCI6Ijd4ZUdxallQd09yOUxSQTNBVm9haGpqeXplSSIsImF1ZCI6Ijk5ODdmNTg5LTYwZDAtNGU4MC1hMmFmLTJlOTI2OGQ3N2RjYyIsIm5iZiI6MTY4MzYyNzk3MCwiZ3JhbnRfdHlwZSI6ImNsaWVudF9jcmVkZW50aWFscyIsInNjb3BlIjpbIm1haWwiXSwiYXV0aF90aW1lIjoxNjgzNjI3OTcwLCJyZWFsbSI6Ii8iLCJleHAiOjE2ODM2Mjk3NzAsImlhdCI6MTY4MzYyNzk3MCwiZXhwaXJlc19pbiI6MTgwMCwianRpIjoiWXFKTmtQOHNiNTI0cnpuTUNsLVB3NVc1WnM0IiwiY2xpZW50X2lkIjoiOTk4N2Y1ODktNjBkMC00ZTgwLWEyYWYtMmU5MjY4ZDc3ZGNjIn0.PUmKF921_sgo3r9cgvkuOJsn-e4ROrzQFpd7PdzmqNLP_37GdOA9YEuGysmyaaviCUwBko-JHSjHbqpCo7XJ3_5axL9blLGeLjnpulj93KHrRYK0HFo4NznPCSsTs5IW25GjCPL-nw5-VUWGWhEdLGVVbNPjFnWcYBISWBWLB1KhigIO8jntwgRv1QT3CVoygtJXe_a4glWroc7Ef4Q9W6AlfjNAwJIoPzIX1V2ETtoT_tf0NJup28w2xiNONw9lamCq5S1OUqSaQX9IzRzWmSxKWfloZ8ChM2Gg9VwIVjKrnQIo80pRtckKZ6oNpmyQuZuzR0-vaXvaYDlo5v8JJA';
        String amountval = '"amount"';
        String typepair = '"_type": "money"';
        String money = '"value": 35.00';
        String currencymem = '"currency_mnemonic": "GBP"';
        String ordernumberpair = '"order_no": "0000011604_dev9_web4"';
        String valuepair ='"value": 35.00';
        String body=	'{\n"_v": "22.10",\n'+
            			'"_type": "gift_certificate_search_result",\n'+
            			'"count": 2,\n'+
            			'"hits": [\n'+
            			'{\n'+
                        '"type": "gift_certificate",\n'+
                        '"_resource_state": "a66b52cbc8c128cc3a19f2a0ec6d9972c254f3d91083c0cf476aeb1ef8e226d8",\n'+
                        amountval+': {\n'+
                        typepair+',\n'+
                        currencymem+',\n'+
                        money+'\n'+
                        '},\n'+
            			'"balance": {\n'+
                         typepair+',\n'+
                        currencymem+',\n'+
            			money+'\n'+
            			'},\n'+
            			'"creation_date": "2023-05-04T10:28:03.000Z",\n'+
            			'"description": "my-description",\n'+
            			'"enabled": true,\n'+
                        '"last_modified": "2023-05-04T10:28:03.000Z",\n'+
                        '"link": "https://development-direct.asda.com/s/-/dw/data/v22_10/sites/ASDA/gift_certificates/05035882",\n'+
            			'"masked_gift_certificate_code": "************LFHV",\n'+
            			'"merchant_id": "05035882",\n'+
                        '"message": "my-message",\n'+
            ordernumberpair+',\n'+
            '"recipient_email": "radu.popescu1@publicissapient.com",\n'+
            '"recipient_name": "Radu",\n'+
            			'"sender_name": "my-sender_name",\n'+
            			'"status": "issued",\n'+
            '"transactions": [\n'+
                '{\n'+
                    '"_type": "account_transaction",\n'+
                    amountval+': {\n'+
                         typepair+',\n'+
                        currencymem+',\n'+
                        valuepair+'\n'+
                    '},\n'+
                    ordernumberpair+',\n'+
                    '"timestamp": "2023-05-04T10:28:03.000Z",\n'+
                    '"type_code": "create"\n'+
                '}\n'+
            '],\n'+
            '"c_crm_id": "0033H00000QDkreQAD",\n'+
            '"c_expiryDate": "3023-06-03T23:59:59.000Z",\n'+
            '"c_expiry_reminder_sent": false\n'+
        '}\n'+
    '],\n'+
    '"query": {\n'+
        '"bool_query": {\n'+
            '"_type": "bool_query",\n'+
            '"must": [\n'+
                '{\n'+
                    '"text_query": {\n'+
                        '"_type": "text_query",\n'+
                        '"fields": [\n'+
                            '"c_crm_id"\n'+
                        '],\n'+
                        '"search_phrase": "0033H00000QDkreQAD"\n'+
                    '}\n'+
                '}\n'+
            ']\n'+
        '}\n'+
    '},\n'+
    '"select": "(**)",\n'+
    '"start": 0,\n'+
    '"total": 2\n'+
'}\n';
        
        HttpResponse response = new HttpResponse();
        
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('Authorization', 'Bearer '+ accesstoken);
        response.setStatusCode(200);
        return response;
    }

}