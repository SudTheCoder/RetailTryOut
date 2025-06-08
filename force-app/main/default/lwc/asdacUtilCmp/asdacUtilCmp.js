export {checkPhoneNumberFormats,filterAcceptedFiles, decodeSpecialCharacters};

function checkPhoneNumberFormats(countryCodeFld, phoneFld) {
    let regex = /^\d+$/;
    phoneFld.setCustomValidity("");
    if(phoneFld.value) {
        if(!regex.test(phoneFld.value)){
            phoneFld.setCustomValidity("Only Numbers are allowed");
        }
        //Ireland Phone Validation
        else if(countryCodeFld.value === '353') {
            phoneFld = irelandPhoneValidation(phoneFld);
        }
        //India Phone Validation
        else if(countryCodeFld.value === '91') {
            phoneFld = indiaPhoneValidation(phoneFld);
        }
        //Pakistan Phone Validation
        else if(countryCodeFld.value === '92') {
            phoneFld = pakistanPhoneValidation(phoneFld);
        }
        //Poland Phone Validation
        else if(countryCodeFld.value === '48') {
            phoneFld = polandPhoneValidaiton(phoneFld);
        }
        //UK Phone Validation
        else if(countryCodeFld.value === '44') {
            phoneFld = ukPhoneValidation(phoneFld);
        }
        //Other Country Phone Validation
        else {
            phoneFld = otherCountryPhoneValidaiton(phoneFld);
        }
    }
    phoneFld.reportValidity();
}

function irelandPhoneValidation(phoneFld) {
    phoneFld.setCustomValidity("Please provide 0 before Phone.");
    if(phoneFld.value.startsWith('0')) { 
        if(phoneFld.value.startsWith('08')) {
            phoneFld.setCustomValidity("Phone Starting from 08 must be of 10 digits.");
            if(phoneFld.value.length === 10) {
                phoneFld.setCustomValidity("");
            }
        } 
        else {
            phoneFld.setCustomValidity("The Phone must be of between 7 to 11 digits long.");
            if(phoneFld.value.length >= 7 && phoneFld.value.length <= 11) {
                phoneFld.setCustomValidity("");
            }
        }         
    }
    return phoneFld;
}

function indiaPhoneValidation(phoneFld) {
    phoneFld.setCustomValidity("The Phone should not start with 0.");
    if(!phoneFld.value.startsWith('0')) { 
        phoneFld.setCustomValidity("The Phone should be of 10 digits.");
        if(phoneFld.value.length === 10) { 
            phoneFld.setCustomValidity("");
        }
    }
    return phoneFld;
}

function pakistanPhoneValidation(phoneFld) {
    phoneFld.setCustomValidity("Please provide 0 before Phone.");
    if(phoneFld.value.startsWith('0')) { 
        phoneFld.setCustomValidity("The Phone should be of 11 digits.");
        if(phoneFld.value.length === 11) { 
            phoneFld.setCustomValidity("");
        }
    }
    return phoneFld;
}

function polandPhoneValidaiton(phoneFld) {
    phoneFld.setCustomValidity("The Phone should not start with 0.");
    if(!phoneFld.value.startsWith('0')) { 
        phoneFld.setCustomValidity("The Phone should be of 9 digits.");
        if(phoneFld.value.length === 9) { 
            phoneFld.setCustomValidity("");
        }
    }
    return phoneFld;
}

function ukPhoneValidation(phoneFld) {
    phoneFld.setCustomValidity("Please provide 0 before Phone.");
    if(phoneFld.value.startsWith('0')) { 
        if(phoneFld.value.startsWith('01')) {
            phoneFld.setCustomValidity("The Phone must be of 10 or 11 digits long.");
            if(phoneFld.value.length === 10 || phoneFld.value.length === 11) {
                phoneFld.setCustomValidity("");
            }
        }
        else if(!phoneFld.value.startsWith('08') && !phoneFld.value.startsWith('09')) {
            phoneFld.setCustomValidity("The Phone must be of 11 digits long.");
            if(phoneFld.value.length === 11) {
                phoneFld.setCustomValidity("");
            }
        }
        else {
            phoneFld = ukPhoneValidationHelper(phoneFld);
        }
    }
    return phoneFld;
}

function ukPhoneValidationHelper(phoneFld) {
    phoneFld.setCustomValidity("");
    if(phoneFld.value.startsWith('08') || phoneFld.value.startsWith('09')) {
        phoneFld.setCustomValidity("The Phone starts from 08 and 09 cannot be used. As they are premium numbers which would not be used by customers.");
    }
    return phoneFld;
}

function otherCountryPhoneValidaiton(phoneFld) {
    phoneFld.setCustomValidity("All Phone must have between 6 and 12 digits in total.");
    if(phoneFld.value.length >=6 && phoneFld.value.length <=12) {
        phoneFld.setCustomValidity("");
    }
    return phoneFld;  
}

function fileFormatMap(){
    return new Map([
        ['text/plain',".txt"],
        ["image/jpeg",".jpg"],
        ["image/jpeg",".jpeg"],
        ["image/png",".png"],
        ["image/gif",".gif"],
        ["image/svg+xml",".svg"],
        ["application/pdf",".pdf"],
        ["text/csv",".csv"],
        ["application/vnd.ms-powerpoint",".ppt"],
        ["application/vnd.openxmlformats-officedocument.presentationml.presentation",".pptx"],
        ["application/xml",".xml"],
        ["application/msword",".doc"],
        ["application/vnd.openxmlformats-officedocument.wordprocessingml.document",".docx"],
        ["application/rtf",".rtf"],
        ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",".xlsx"],
        ["application/x-msdownload",".exe"],
      ])
}
function filterAcceptedFiles(selectedFiles,acceptedFiles) {
    if(acceptedFiles){
        const fileTypeMap=fileFormatMap();
        const acceptedFileArray=acceptedFiles.split(',') ||[];
        for(let file of selectedFiles){
            // either not exists in fileTypeMap or not in accepted file formats | remove from selected files
            if (!fileTypeMap.get(file.type) || !acceptedFileArray.includes(fileTypeMap.get(file.type))) {
                selectedFiles.splice(selectedFiles.indexOf(file), 1);
            }
        }
    } 
    return selectedFiles;
}

function decodeSpecialCharacters(csvData){
    return csvData.replace(/&(amp|quot|lt|gt|#39);/g, (match, entity) => {
        const entities = {
            'amp': '&',
            'quot': '""',
            'lt': '<',
            'gt': '>',
            '#39': "'"
        };
        return entities[entity];
    });
}