import { LightningElement,api } from 'lwc';

export default class Quotecontainers extends LightningElement {
    connectedCallback(){
        console.log("@@@@@@@@@@@@@@@@@@ Componnet Created @@@@@");
    }
    //Invoke Method: called when action is called
    @api invoke(){
        console.log('@@@@@@@ ACTION CaLLED @@@@');
    }
    
}