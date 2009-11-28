function addrow(operation) {
     var operationType = document.getElementById(operation);
     var set = operationType.getElementsByClassName('sof')[0];

     var length = set.getElementsByClassName('row').length;

     var rows = set.getElementsByClassName('row');
     var lastRow = rows[rows.length - 1];

     var to_date = lastRow.getElementsByClassName('time-info-text-date')[1].value;
     var to_time = lastRow.getElementsByClassName('time-info-text-time')[1].value;
     var to = Date.parseExact(to_date, "dd-MM-yy");
     if(to == null) {
       alert('Please enter the date in format dd-mm-yy for to');
       return false;
     }
     var hr = parseInt(to_time.split(':')[0], 10);
     var min = parseInt(to_time.split(':')[1], 10);
     if(!hr || !min) {
       alert('Please enter the to time in format hh:mm');
       return false;
     }
     to.set({hour: hr, minute: min});

     var from_date = lastRow.getElementsByClassName('time-info-text-date')[0].value;
     var from_time = lastRow.getElementsByClassName('time-info-text-time')[0].value;
     var from = Date.parseExact(from_date, "dd-MM-yy");
     if(from == null) {
       alert('Please enter the date in format dd-mm-yy for from');
       return false;
     }

     var hr = parseInt(from_time.split(':')[0], 10);
     var min = parseInt(from_time.split(':')[1], 10);

     if(!hr || !min) {
       alert('Please enter the from time in format hh:mm');
       return false;
     }

     from.set({hour: hr, minute: min});

     if(from > to) {
       alert('From can not be greater that to. Please correct and try again');
       return false;
     }

     var commence_date = document.getElementById('port_detail_time_start_date_' + operation).value;
     var commence_time = document.getElementById('port_detail_time_start_time_' + operation).value;
     var commence = Date.parseExact(commence_date, "dd-MM-yy");

     if(commence == null) {
       alert('Please enter the Laytime Commence date in format dd-mm-yy');
       return false;
     }

     var hr = parseInt(commence_time.split(':')[0], 10);
     var min = parseInt(commence_time.split(':')[1], 10);

     if(!hr || !min) {
       alert('Please enter the laytime commence time in format hh:mm');
       return false;
     }
     commence.set({hour: hr, minute: min});

     var complete_date = document.getElementById('port_detail_time_end_date_' + operation).value;
     var complete_time = document.getElementById('port_detail_time_end_time_' + operation).value;
     var complete = Date.parseExact(complete_date, "dd-MM-yy");

     if(complete == null) {
       alert('Please enter the Laytime complete date in format dd-mm-yy');
       return false;
     }

     var hr = parseInt(complete_time.split(':')[0], 10);
     var min = parseInt(complete_time.split(':')[1], 10);

     if(!hr || !min) {
       alert('Please enter the laytime complete time in format hh:mm');
       return false;
     }
     complete.set({hour: hr, minute: min});

     /* from and to datetime should be greater than equal commence date and 
        less than equal complete date */

     /* TODO Add validation to check for continuity */
     
     if(from < commence) {
       alert('From can not be less than laytime commence date');
       return false;
     }

     if(from >= complete) {
       alert('From can not be greater than laytime complete date');
       return false;
     }

     if(to <= commence) {
       alert('To can not be less than laytime commence date');
       return false;
     }

     if(to > complete) {
       alert('To can not be greater than laytime complete date');
       return false;
     }

     /* 
      To of this sof is the from of next. 
      Get the to of the last sof and populate the from of new sof
     */

     var row = document.createElement('div')
     row.setAttribute('class','row');

     var label = document.createElement('label');
     label.setAttribute('id', 'from_' + operation + '_' + length);
     label.innerHTML = getDay(to);
     row.appendChild(label);

     var input = document.createElement('input');
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

     var label = document.createElement('label');
     label.setAttribute('id', 'to_' + operation + '_' + length);
     label.innerHTML = "---";
     row.appendChild(label);

     input = document.createElement('input')
     input.setAttribute('class','time-info-text-date');
     input.setAttribute('type','text');
     input.setAttribute('id','to_date_'+operation+'_'+length);
     input.setAttribute('name',operation+'[][to_date]');
     input.setAttribute('value',"dd-mm-yy");
     input.setAttribute('onblur',"displayDayLabel(this.value, 'to', '" + operation + "', " + length + ");");
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

function displayDayLabel(value, type, operation, index) {
  var element = document.getElementById(type + '_' + operation + '_' + index);
  var d = Date.parseExact(value, "dd-MM-yy");
  // Month starts from 0 in datejs which sucks. Increment by a month and then
  // take the day.
  element.innerHTML = getDay(d);
}

function getDay(d) {
  if(d) {
    d.add ({months: 1});
    return d.getDayName().substring(0,3);
  } else {
    return "---";
  }

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
