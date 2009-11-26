function addrow(operation) {
     var operationType = document.getElementById(operation);
     var set = operationType.getElementsByClassName('sof')[0];

     var length = set.getElementsByClassName('row').length;

    /* 
      To of this sof is the from of next. 
      Get the to of the last sof and populate the from of new sof
     */

     var rows = set.getElementsByClassName('row');
     var lastRow = rows[rows.length - 1];
     var to_date = lastRow.getElementsByClassName('time-info-text-date')[1].value;
     var to_time = lastRow.getElementsByClassName('time-info-text-time')[1].value;

     var row = document.createElement('div')
     row.setAttribute('class','row');

     var input = document.createElement('input')
     input.setAttribute('class','time-info-text-date');
     input.setAttribute('type','text');
     input.setAttribute('name',operation+'[][from_date]');
     input.setAttribute('id','from_date_'+operation+'_'+length);
     input.setAttribute('value',to_date);
     input.setAttribute('onfocus',"if(this.getValue() == 'hh:mm' || this.getValue() == 'dd-mm-yy') {this.clear();}");
     row.appendChild(input);

     input = document.createElement('input')
     input.setAttribute('class','time-info-text-time');
     input.setAttribute('type','text');
     input.setAttribute('id','from_time_'+operation+'_'+length);
     input.setAttribute('name',operation+'[][from_time]');
     input.setAttribute('value',to_time);
     input.setAttribute('onfocus',"if(this.getValue() == 'hh:mm' || this.getValue() == 'dd-mm-yy') {this.clear();}");
     row.appendChild(input);

     input = document.createElement('input')
     input.setAttribute('class','time-info-text-date');
     input.setAttribute('type','text');
     input.setAttribute('id','to_date_'+operation+'_'+length);
     input.setAttribute('name',operation+'[][to_date]');
     input.setAttribute('value',"dd-mm-yy");
     input.setAttribute('onfocus',"if(this.getValue() == 'hh:mm' || this.getValue() == 'dd-mm-yy') {this.clear();}");
     row.appendChild(input);

     input = document.createElement('input')
     input.setAttribute('class','time-info-text-time');
     input.setAttribute('type','text');
     input.setAttribute('id','to_time_'+operation+'_'+length);
     input.setAttribute('name',operation+'[][to_time]');
     input.setAttribute('value',"hh:mm");
     input.setAttribute('onfocus',"if(this.getValue() == 'hh:mm' || this.getValue() == 'dd-mm-yy') {this.clear();}");
     row.appendChild(input);

     input = document.createElement('input')
     input.setAttribute('class','ttc');
     input.setAttribute('type','text');
     input.setAttribute('name',operation+'[][timeToCount]');
     row.appendChild(input);

     input = document.createElement('input')
     input.setAttribute('class','pct');
     input.setAttribute('type','text');
     input.setAttribute('name',operation+'[][val]');
     row.appendChild(input);

     input = document.createElement('input')
     input.setAttribute('class','rem');
     input.setAttribute('type','text');
     input.setAttribute('name',operation+'[][remarks]');
     row.appendChild(input);
     set.appendChild(row);
     row.scrollTop = row.scrollHeight;
}

function isValidFacts() {
  var set = document.getElementById('set');
  var list = set.childNodes;
  var valid = true;
  for(var i=0; i< list.length; i++) {
    if(list[i].children != undefined) {
      var collection = list[i].children
      if(collection.length == 5 && collection[0].localName == "INPUT") {
        for(var j=0; j<collection.length; j++) {
          if(collection[j].value == "") {
            valid = false;
          }
        }
      }
    }
  }
  if(!valid) {
    alert("Please fill in all the fields and try");
    return false;
  } else {
    alert("All Good");
    return true;
  }
}
