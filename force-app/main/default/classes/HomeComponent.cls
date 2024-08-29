public class HomeComponent{

    public PageReference RedirectToHomeDashBoard(){
        PageReference pr = new PageReference('/01Z61000000e3ZC');
        pr.setRedirect(true);
        return pr;
    }
    
}