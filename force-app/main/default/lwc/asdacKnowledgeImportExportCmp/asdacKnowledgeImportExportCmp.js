import { api, LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference } from "lightning/navigation";
import importKnowledge from "@salesforce/apex/ASDAC_KnowledgeController.importKnowledge";
import exportKnowledge from "@salesforce/apex/ASDAC_KnowledgeController.exportKnowledge";
import getFields from "@salesforce/apex/ASDAC_KnowledgeController.getFields";
import { decodeSpecialCharacters } from 'c/asdacUtilCmp';

export default class AsdacKnowledgeImportExportCmp extends LightningElement {
  tab = "import";
  sampleFAQLink;
  @api batchSize = 100;
  files;
  data = [];
  columns = [];
  pageNumber = 1;
  pageSize = 5;
  pageSizes = Array(5)
    .fill(0)
    .map((v, i) => 5 * (i + 1))
    .map((v) => ({ label: v, value: v }));
  loading = false;
  recordType;
  recordTypes = [{ label: "FAQ", value: "FAQ" }];
  publishStatus;
  publishStatuses = [
    { label: "Any", value: "any" },
    { label: "Published", value: "published" },
    { label: "Draft", value: "draft" }
  ];

  get isExport() {
    return this.tab === "export";
  }
  get isSample(){
    return this.sampleFAQLink==='Download';
  }

  get importVariant() {
    return !this.isExport && !this.isSample? "brand" : "neutral";
  }

  get exportVariant() {
    return this.isExport && !this.isSample? "brand" : "neutral";
  }
  get downloadVariant() {
    return this.isSample? "brand" : "neutral";
  }
  get showData() {
    return this.data && this.data.length > 0;
  }

  get pageStart() {
    return (this.pageNumber - 1) * this.pageSize + 1;
  }

  get pageEnd() {
    return Math.min(this.pageNumber * this.pageSize, this.data.length);
  }

  get pageData() {
    return this.data.slice(this.pageStart - 1, this.pageEnd).map((article) => ({
      ...article,
      Keywords: article.Keywords.join(", "),
      Categories: article.Categories.join(", ")
    }));
  }

  get disablePrevious() {
    return this.pageNumber <= 1;
  }

  get disableNext() {
    return this.pageEnd >= this.data.length;
  }

  get exportValid() {
    return this.recordType && this.publishStatus;
  }

  get isDownloadable() {
    return this.tab === "export" || this.sampleFAQLink==='Download';
  }

  @wire(CurrentPageReference)
  getPageReference(pageRef) {
    const state = pageRef.state || {};
    this.tab = state.c__tab;
  }

  handleButtonClick(evt) {
    this.tab = evt.target.label.toLowerCase();
    this.sampleFAQLink='';
  }

  handlePageChange(evt) {
    const change = Number(evt.target.name);
    this.pageNumber += change;
  }

  handleChange(evt) {
    const name = evt.target.name;
    const value = evt.detail.value;
    if ((value || "").match(/\d+/g)) {
      this[name] = Number(value);
    } else {
      this[name] = value;
    }
  }

  handleFileChange(evt) {
    this.files = evt.detail.value;
    if (this.files.length > 0) {
      this.parseCsv(this.files[0]);
    } else {
      this.data = [];
    }
  }

  async parseCsv(file, delimiter = ",") {
    try {
      this.loading = true;
      const text = await file.text();
      const pattern = new RegExp(
        "(\\" +
          delimiter +
          "|\\r?\\n|\\r|^)" +
          '(?:"([^"]*(?:""[^"]*)*)"|' + // Quoted fields
          '([^"\\' +
          delimiter +
          "\\r\\n]*))", // Standard fields
        "gi"
      );
      const data = [[]];
      let match;
      while ((match = pattern.exec(text))) {
        // Get the delimiter that was found.
        let matchedDelimiter = match[1];
        // Check to see if the given delimiter has a length
        // (is not the start of string) and if it matches
        // field delimiter. If id does not, then we know
        // that this delimiter is a row delimiter.
        if (matchedDelimiter.length && matchedDelimiter !== delimiter) {
          // Since we have reached a new row of data,
          // add an empty row to our data array.
          data.push([]);
        }
        // Now that we have our delimiter out of the way,
        // let's check to see which kind of value we
        // captured (quoted or unquoted).
        let matchedValue = null;
        if (match[2]) {
          // We found a quoted value. When we capture
          // this value, unescape any double quotes.
          matchedValue = match[2].replace(/""/g, '"');
        } else {
          // We found a non-quoted value.
          matchedValue = match[3];
        }
        // Now that we have our value string, let's add
        // it to the data array.
        data[data.length - 1].push(matchedValue);
      }
      this.columns = [];
      const fields = data.splice(0, 1)[0].map((label) => {
        const field = label.trim();
        this.addFieldToColumns(field);
        return field;
      });
      this.data = this.convertToJson(data, fields);
      this.pageNumber = 1;
      this.loading = false;
    } catch (error) {
      this.handleError(new Error("Invalid File"));
      this.files = [];
      this.data = [];
    }
  }

  addFieldToColumns(field) {
    if (!["Id", "Answer", "Summary"].includes(field)) {
      this.columns.push({ label: field, fieldName: field, wrapText: true });
    }
  }

  convertToJson(data, fields) {
    return data
      .map((row) => {
        const json = {};
        fields.forEach((field, index) => {
          const value = row[index] || "";
          if (value.toLowerCase() === "true" || value.toLowerCase() === "false") {
            json[field] = value.toLowerCase() === "true";
          } else {
            json[field] = value;
          }
        });
        delete json.Id;
        json.Keywords = this.splitString(json.Keywords);
        json.Categories = this.splitString(json.Categories);
        return json;
      })
      .filter((json) => json.Title);
  }

  splitString(str, delimiter = ",") {
    return str
      .split(new RegExp(delimiter, "g"))
      .map((word) => (word || "").trim())
      .filter((word) => word);
  }

  async importArticles() {
    if (!this.template.querySelector("lightning-combobox").reportValidity()) {
      return;
    }

    this.loading = true;
    const data = [...this.data];
    let start = 0;
    let successCount = 0;
    const errors = [];
    while (data.length > 0) {
      const batchData = data.splice(0, this.batchSize);
      try {
        successCount += await importKnowledge({ recordType: this.recordType, articleList: batchData });
      } catch (error) {
        errors.push({ error, title: `Articles ${start + 1}-${start + batchData.length}` });
      }
      start += batchData.length;
    }
    if (successCount) {
      const event = new ShowToastEvent({
        title: "Success",
        variant: "success",
        message: `${successCount} Articles (${this.recordType}) imported`
      });
      this.dispatchEvent(event);
    }
    errors.forEach((e) => this.handleError(e.error, e.title));
    if (errors.length === 0) {
      this.data = [];
      this.files = [];
    }
    this.loading = false;
  }

  exportArticles() {
    if (!this.template.querySelector("lightning-combobox").reportValidity()) {
      return;
    }

    this.loading = true;
    getFields({ recordType: this.recordType })
      .then((fields) => {
        exportKnowledge({ recordType: this.recordType, publishStatus: this.publishStatus }).then((data) => {
          const header = fields;
          const csvData = [header.join(",")]
            .concat(
              data.map((article) => {
                return header
                  .map((key) => {
                    const value = article[key];
                    if (Array.isArray(value)) {
                      return `"${value.join(", ")}"`;
                    } else if (typeof value === "string" && (value.includes('"') || value.includes(","))) {
                      return `"${value.replace(/"/g, '""')}"`;
                    }
                    return value;
                  })
                  .join(",");
              })
            )
            .join("\n");
          this.generateCSVFileLink(csvData,'export');
          this.loading = false;
        });
      })
      .catch(this.handleError.bind(this));
  }

  handleError(error, title = "Error") {
    console.error(error);
    let message;
    if (Array.isArray(error)) {
      message = error[0];
    } else if (error.body) {
      message = error.body.message;
    } else {
      message = error.message;
    }
    if (message.includes("access")) {
      message = "Insufficient Privileges";
    }
    const event = new ShowToastEvent({
      title,
      variant: "error",
      message
    });
    this.dispatchEvent(event);
    this.loading = false;
  }

  downloadSampleFAQ(evt){
    this.sampleFAQLink = evt.target.title;
    this.recordType = evt.target.value;
    this.loading = true;
    getFields({ recordType: this.recordType })
      .then((fields) => {
          const csvData = fields.join(",");
          this.generateCSVFileLink(csvData,'sample');
          this.loading = false;
      })
      .catch(this.handleError.bind(this));
  }

 generateCSVFileLink(csvData, fileType){
  csvData = decodeSpecialCharacters(csvData);
  const csv = new Blob([csvData], { type: "text/plain", encoding: "UTF-8", endings: "native" });
  const uri = window.URL.createObjectURL(csv);
  const linkEl = this.template.querySelector('a');
  linkEl.target = "_blank";
  linkEl.href = uri;
  linkEl.download = ((fileType==='sample')? 'Sample-':'') + this.recordType + ".csv";
  linkEl.click();
  linkEl.href = "";
 }
}