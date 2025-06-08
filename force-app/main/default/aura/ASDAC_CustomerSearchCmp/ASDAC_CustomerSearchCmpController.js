({
	/**************************************************************************
     Method is called when "opennewcustomer" event is sent by 
     asdacCustomerSearch LWC and Aura received it. This function will enable 
     the overlay modal popup and embed "asdacCreateNewCustomerCmp" as body and 
     "asdacCreateNewCustomerFooterCmp" as footer component.
    **************************************************************************/
	handleNewCustomer : function(component, event, helper) {
		component.set('v.components', []);
		$A.createComponents(
            					[["c:asdacCreateNewCustomerCmp",{
                                    "accountRec":event.getParam('accountObj'),
                                    "onduplicateexists" : component.getReference("c.handleDuplicates"),
                                    "onredirecttocustomer" : component.getReference("c.handleRedirectToCustomer"),
                                    "onhandleOnEnterPress" : component.getReference("c.handleSubmit")
                                }],
                                 ["c:asdacCreateNewCustomerFooterCmp", {
                                     "onsubmit" : component.getReference("c.handleSubmit"),
                                     "oncancel" : component.getReference("c.handleCancel"),
                                     "onupdate" : component.getReference("c.handleUpdate"),
                                     "oncreatenew" : component.getReference("c.handleCreateNew")
                                 }]],
		function(components, status) {
			if (status === "SUCCESS") {
				component.find('overlayLib').showCustomModal({
					header: "New Customer",
					body: components[0], 
                    footer: [components[1]],
					showCloseButton: true,
					cssClass : "slds-modal_large",
					closeCallback: function(ovl) {
					}
				}).then(function(overlay){
                    component.set('v.components', components);
                    component._overlay = overlay;
				});
			}
		});
	},
    
	/**************************************************************************
     Method is called when "cancel" event is sent by 
     asdacCreateNewCustomerFooterCmp LWC. This function will close the overlay
     modal popup.
    **************************************************************************/	
	handleCancel : function(component, event, helper) {
        if (component._overlay) {
            //Added because cancel was not working when call from - 
            //"New Customer" button
            Promise.resolve().then(() => {
                component._overlay.close();
            	component._overlay = null;
            });
        } 
	},
    
	/**************************************************************************
     Method is called when "submit" event is sent by 
     asdacCreateNewCustomerFooterCmp LWC. This function will call the 
     @api handleSubmit method from body "asdacCreateNewCustomerCmp" component.
    **************************************************************************/    
    handleSubmit : function(component, event, helper) { 
        let bodyCmp = component.get('v.components')[0]; // getting body component
        
        bodyCmp.handleSubmit();
	}, 
    
	/**************************************************************************
     Method is called when "duplicateexists" event is sent by 
     "asdacCreateNewCustomerCmp" LWC. When any duplicates found with same email/
     same phone then we have to hide the "Create New" button from the
     "asdacCreateNewCustomerFooterCmp" footer component. So that Agent shouldn't
     Create a customer record with same email/same phone.
    **************************************************************************/ 
    handleDuplicates : function(component, event, helper) {
        let footerCmp = component.get('v.components')[1]; // getting footer component
        footerCmp.showModifyHandler();	
        if(event.getParam('showCreateNew')) {
            footerCmp.showNewHandler();
        }
    },
    
	/**************************************************************************
     Method is called when "update" event is sent by 
     "asdacCreateNewCustomerFooterCmp" LWC. on receiving of this event we are 
     enabling the inputs again and hiding the "Create New" and "Update" buttons. 
    **************************************************************************/     
    handleUpdate : function(component, event, helper) {
		let bodyCmp = component.get('v.components')[0]; // getting body component
        bodyCmp.handleUpdate(); 
        let footerCmp = component.get('v.components')[1]; // getting footer component
        footerCmp.hideNewAndResetHandler();	          
	},
    
	/**************************************************************************
     Method is called when "createnew" event is sent by 
     "asdacCreateNewCustomerFooterCmp" LWC. on receiving of this event body's
     component @api handleCreateNew function is called.
    **************************************************************************/    
    handleCreateNew : function(component, event, helper) {
		let bodyCmp = component.get('v.components')[0]; // getting body component
        bodyCmp.handleCreateNew(); 
	},
    
	/**************************************************************************
     Method is called when "Clear" button is clicked
    **************************************************************************/
    handleClear : function(component, event, helper) {
		component.set('v.components', []);        
    },
    
    doInit : function(component, event, helper) {
        let pageRef = component.get("v.pageReference");
        if(pageRef && pageRef.state && pageRef.state.c__source === 'listviewbutton') {
            component.set('v.isOpenedFromListViewBtn', true);
			let workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                let focusedTabId = response.tabId;
                component.set('v.newCustomerTab', focusedTabId);
                workspaceAPI.setTabLabel({
                    //tabId : focusedTabId,
                    label: 'New Customer'
                });
                workspaceAPI.setTabIcon({
                    //tabId : focusedTabId,
                    icon : 'standard:people',
                    iconAlt : 'New Customer'
                });
            })            
        }
    },
    
    handleRedirectToCustomer : function(component, event, helper) {
        let workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '#/sObject/' + event.getParam('customerId') + '/view',
            focus: true
        });
        if(component.get('v.isOpenedFromListViewBtn')) {
			workspaceAPI.closeTab({
                tabId : component.get('v.newCustomerTab')           
            });            
        } else {
            let handleMinimizeTab = component.get('c.handleMinimizeTab');
            $A.enqueueAction(handleMinimizeTab);
        }
    },

    /**************************************************************************
     Method is called when "minimizetab" event is sent by 
     asdacCustomerSearch LWC. This function will minimize the utility tab.
    **************************************************************************/	
    handleMinimizeTab : function(component, event, helper) {
        let utilityAPI = component.find("utilitybar");
        utilityAPI.minimizeUtility();
    },

    handleOpenOrderDetailEvent : function(component, event) {
        let orderId = event.getParam('uid');
        let businessArea = event.getParam('c__businessArea');
        let cardReference = event.getParam('c__cardRef');
        let workspaceAPI = component.find("workspace");
        let tabName = '';
        if(orderId == undefined || orderId == ''){
            orderId = 'blank';
            if(cardReference != null){
                tabName = cardReference;
            }else{
                tabName = '';
            }
        }else{
            tabName = orderId;
        }
        
        workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
            workspaceAPI.openTab({
                pageReference: {
                    "type": "standard__component",
                    "attributes": {
                        "componentName": "c__ASDAC_DisplayOrdersCmp"
                    },
                    "state": {
                        "uid": orderId,
                        "c__businessArea":businessArea,
                        "c__cardRef": cardReference,
                        "c__searched": true
                    }
                }
            }).then(function(subtabId) {
                workspaceAPI.setTabLabel({
                    tabId : subtabId,
                    label: tabName
                });
                workspaceAPI.setTabIcon({
                    tabId : subtabId,
                    icon : 'standard:orders',
                    iconAlt : orderId
                });
            }).catch(function(error) {
                console.log("error");
                console.log(error);
            });
        });
    },
})