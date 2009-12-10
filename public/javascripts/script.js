function doValidation(operation) {
     var operationType = $(operation);
     var sofSet = operationType.getElementsByClassName('sof')[0];

     var length = sofSet.getElementsByClassName('row').length;

     var rows = sofSet.getElementsByClassName('row');
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
     
     try {
       to.set({hour: hr, minute: min});
     } catch(error) {
       alert('Please make sure the hour and minute values are valid for to.');
       return false;
     }

     var from_date = lastRow.getElementsByClassName('time-info-text-date')[0].value;
     var from_time = lastRow.getElementsByClassName('time-info-text-time')[0].value;
     var from = Date.parseExact(from_date, "dd-MM-yy");
     if(from == null) {
       alert('Please enter the date in format dd-mm-yy for from');
       return false;
     }

     var hr = parseInt(from_time.split(':')[0], 10);
     var min = parseInt(from_time.split(':')[1], 10);

     try {
       from.set({hour: hr, minute: min});
     } catch(error) {
       alert('Please make sure the hour and minute values are valid for from.');
       return false;
     }


     if(from > to) {
       alert('From can not be greater that to. Please correct and try again');
       return false;
     }

     var commence_date = $('port_detail_time_start_date_' + operation).value;
     var commence_time = $('port_detail_time_start_time_' + operation).value;
     var commence = Date.parseExact(commence_date, "dd-MM-yy");

     if(commence == null) {
       alert('Please enter the Laytime Commence date in format dd-mm-yy');
       return false;
     }

     var hr = parseInt(commence_time.split(':')[0], 10);
     var min = parseInt(commence_time.split(':')[1], 10);

     try {
       commence.set({hour: hr, minute: min});
     } catch(error) {
       alert('Please make sure the hour and minute values are valid for commence date.');
       return false;
     }

     var complete_date = $('port_detail_time_end_date_' + operation).value;
     var complete_time = $('port_detail_time_end_time_' + operation).value;
     var complete = Date.parseExact(complete_date, "dd-MM-yy");

     if(complete == null) {
       alert('Please enter the Laytime complete date in format dd-mm-yy');
       return false;
     }

     var hr = parseInt(complete_time.split(':')[0], 10);
     var min = parseInt(complete_time.split(':')[1], 10);

     try {
       complete.set({hour: hr, minute: min});
     } catch(error) {
       alert('Please make sure the hour and minute values are valid for complete date.');
       return false;
     }

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

     var pct = lastRow.getElementsByClassName('pct')[0].value;

     if(pct == "") {
       alert("Please enter percentage"); 
       return false;
     }

     return [from_date, from_time, from, to_date, to_time, to, commence, complete, sofSet, pct]
}

function addRow(operation) {
    
    var val = doValidation(operation);
    if(!val) {
      return false;
    }
    var from_date = val[0];
    var from_time = val[1];
    var from = val[2];
    var to_date = val[3];
    var to_time = val[4];
    var to = val[5];
    var commence = val [6];
    var complete = val [7];
    var sofSet = val[8];
    var length = sofSet.getElementsByClassName('row').length;

    if(complete.compareTo(to) == 0) {
      alert("To is equal to Complete date");
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
     row.appendChild(input);

     input = document.createElement('input')
     input.setAttribute('class','time-info-text-time');
     input.setAttribute('type','text');
     input.setAttribute('id','from_time_'+operation+'_'+length);
     input.setAttribute('name',operation+'[][from_time]');
     input.setAttribute('value',to_time);
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
     input.onblur = function() { displayDayLabel(this.value, 'to', operation, length); };
     input.onfocus = function() {if(this.value == 'hh:mm' || this.value == 'dd-mm-yy') {this.value = '';}};
     row.appendChild(input);

     input = document.createElement('input')
     input.setAttribute('class','time-info-text-time');
     input.setAttribute('type','text');
     input.setAttribute('id','to_time_'+operation+'_'+length);
     input.setAttribute('name',operation+'[][to_time]');
     input.setAttribute('value',"hh:mm");
     input.onfocus = function() {if(this.value == 'hh:mm' || this.value == 'dd-mm-yy') {this.value = '';}};
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
     input.onblur = function() { updateRunningInfo(operation, length);};
     row.appendChild(input);

     input = document.createElement('input')
     input.setAttribute('class','rem');
     input.setAttribute('type','text');
     input.setAttribute('name',operation+'[][remarks]');
     row.appendChild(input);
     sofSet.appendChild(row);
}

function displayDayLabel(value, type, operation, index) {
  var element = $(type + '_' + operation + '_' + index);
  var d = Date.parseExact(value, "dd-MM-yy");
  element.innerHTML = getDay(d);
}

function getDay(d) {
  if(d) {
    return d.getDayName().substring(0,3);
  } else {
    return "---";
  }
}

function updateRunningInfo(operation, index) {
  var val = doValidation(operation);
  if(!val) {
    return false;
  }

  var from = val[2];
  var to = val[5];
  var commence = val[6];
  var complete = val[7];
  var sofSet = val[8];
  var pct = val[9];


  var quantity = $F(operation+'_quantity');
  var allowance = $F(operation+'_allowance');

  var totalMins = Math.round((quantity/allowance)*24*60);
  var diffString = getDateDiffString(totalMins);
  
  /* Attach the running total used and available to the row.
     That way you don't need to calculate the running info
     from scratch every time a row is added. */
  var rows = sofSet.getElementsByClassName('row');
  var row = rows[index];

  var running = $(operation + '_usedmins_' + index);
  if(running) {
    row.removeChild(running);
  }

  var used = 0;
  if(index != 0) {
    used = parseInt($(operation + '_usedmins_' + (index - 1)).getAttribute('value'));
  }

  used += Math.round(((to - from)*(pct/100))/(1000*60));

  var info = document.createElement('span');
  info.setAttribute('id', operation + '_usedmins_' + index);
  info.setAttribute('hidden', true);
  info.setAttribute('value', used);
  row.appendChild(info);

  var allowed = $(operation + '_allowed');
  allowed.innerHTML = "Total Time Allowed: " + diffString ;

  diffString = getDateDiffString(used)
  var time_used = $(operation + '_used');
  time_used.innerHTML = "Time Used: " + diffString;

  diffString = getDateDiffString(totalMins - used)
  var available = $(operation + '_available');
  available.innerHTML = "Time Available: " + diffString;

  // update demurrage/despatch information now.
  var att = $(operation).childNodes;
  for(var i=0; i< att.length; i++) {
    var nodes = att[i].childNodes;
    for(var j=0; j<nodes.length; j++) {
      if(nodes[j].id == "port_detail_demurrage") {
        return true;
      }
    }
  }
}

function validateAndUpdateFields(operation) {
  var att = $(operation).childNodes;
  var demurrage = "";
  for(var i=0; i< att.length; i++) {
    var li = att[i].childNodes;
    for(var j=0; j<li.length; j++) {
      if(li[j].id == "port_detail_demurrage") {
        if(li[j].value == "") {
          alert("Please fill demurrage value");
          return false;
        } else {
          demurrage = li[j].value;
        }
      } else if(li[j].id == "port_detail_despatch") {
        li[j].value = demurrage/2;
        document.getElementById('running_' + operation + '_despatch').innerHTML = "Despatch: " + 500;
      }
    }
  }
}

function updateDemurrageDespatch(operation, index) {
  $(operation + '_demurrage');
  $(operation + '_despatch');
}

function getDateDiffString(totalMins) {
  if(totalMins <= 0) {
    return '0 days 0:0';
  }
  var days = parseInt(totalMins/(60*24));
  totalMins -= days*24*60;
  var hours = parseInt(totalMins/60);
  var mins = totalMins - (hours * 60);
  return days + ' days ' + hours + ':' + mins;
}
