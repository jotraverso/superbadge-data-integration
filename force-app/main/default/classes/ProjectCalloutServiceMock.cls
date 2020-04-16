@IsTest
public class ProjectCalloutServiceMock implements HttpCalloutMock {
	public HttpResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(201);
		res.setHeader('Content-Type', 'application/json');
		// res.setBody('{}');
		return res;
	}
}
