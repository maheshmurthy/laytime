function buildDateTime(input_date, input_time, input_type) {
    var parsedDate= Date.parseExact(input_date, "dd-MM-yy");

    if(parsedDate == null) {
      alert('Please enter the date in format dd-mm-yy for ' + input_type);
      return null;
    }

    var hr = parseInt(input_time.split(':')[0], 10);
    var min = parseInt(input_time.split(':')[1], 10);

    try {
      parsedDate.set({hour: hr, minute: min});
    } catch(error) {
      alert('Please make sure the hour and minute values are valid for ' + input_type);
      return null;
    }
    return parsedDate;
}

function doValidation(operation) {
     var operationType = $(operation);
     var sofSet = operationType.getElementsByClassName('sof')[0];

     var length = sofSet.getElementsByClassName('row').length;

     var rows = sofSet.getElementsByClassName('row');
     var lastRow = rows[rows.length - 1];

     var from = buildDateTime(lastRow.getElementsByClassName('time-info-text-date')[0].value, 
          lastRow.getElementsByClassName('time-info-text-time')[0].value,
          "From");
     if(from == null) {
        return false;
     }

     var to = buildDateTime(lastRow.getElementsByClassName('time-info-text-date')[1].value, 
          lastRow.getElementsByClassName('time-info-text-time')[1].value,
          "Until");
     if(to == null) {
        return false;
     }

     if(from > to) {
       alert('From can not be greater than Until. Please correct and try again');
       return false;
     }

     var commence = buildDateTime($('port_detail_time_start_date_' + operation).value, 
          $('port_detail_time_start_time_' + operation).value,
          "Commence Date");
     if(commence == null) {
        return false;
     }
     
     var complete = buildDateTime($('port_detail_time_end_date_' + operation).value, 
          $('port_detail_time_end_time_' + operation).value,
          "complete Date");
     if(complete == null) {
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

     return [from, to, commence, complete, sofSet, pct]
}

function pad(val) {
  val += '';
  if(val.length == 1) {
    return "0" + val; 
  } else {
    return val;
  }
}

function addRow(operation) {
    
    var val = doValidation(operation);
    if(!val) {
      return false;
    }
    var from_date = val[0];
    var from_time = val[0].getHours() + ':' + val[0].getMinutes();
    // Figure out how to build just dd-mm-yy from date
    var to = val[1];
    var to_date = pad(to.getDate()) + "-" + pad((to.getMonth() + 1)) + "-" + (to.getFullYear()+'').substring(2);
    var to_time = val[1].getHours() + ':' + val[1].getMinutes();
    var commence = val [2];
    var complete = val [3];
    var sofSet = val[4];
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

  var from = val[0];
  var to = val[1];
  var commence = val[2];
  var complete = val[3];
  var sofSet = val[4];
  var pct = val[5];


  var quantity = $F(operation+'_quantity');
  var allowance = $F(operation+'_allowance');

  if(quantity == "") {
    alert("Please fill the cargo quantity");
    return false;
  }

  if(allowance == "") {
    alert("Please fill the allowance");
    return false;
  }

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

  var availMins = totalMins - used
  diffString = getDateDiffString(availMins)
  var available = $(operation + '_available');

  var demurrage = $F(operation + '_demurrage');
  var despatch = $F(operation + '_despatch');
  var amount = calculateAmount(availMins, demurrage, despatch);

  if(availMins < 0) {
    available.innerHTML = "Time Over: " + diffString;
    var amt = $('running_' + operation + '_demurrage');
    amt.innerHTML = "Demurrage: " + amount;
  } else {
    available.innerHTML = "Time Available: " + diffString;
    var amt = $('running_' + operation + '_despatch');
    amt.innerHTML = "Despatch: " + amount;
  }
}

function totalAmount(mins, amtPerDay) {
  var days = mins/(60*24);
  return Math.round(days*amtPerDay*100)/100
}

function calculateAmount(availMins, demurrage, despatch) {
  var days = Math.abs(availMins)/(60*24);
  if(availMins > 0) {
    return Math.round(days*despatch*100)/100
  } else {
    return Math.round(days*demurrage*100)/100
  }
}

function validateAndUpdateFields(operation) {
  if($F(operation + '_demurrage') == "") {
    alert("Please enter the demurrage value");
  } else {
    $(operation + '_despatch').value = $F(operation + '_demurrage')/2;
  }
}

function getDateDiffString(totalMins) {
  totalMins = Math.abs(totalMins)
  var days = parseInt(totalMins/(60*24));
  totalMins -= days*24*60;
  var hours = parseInt(totalMins/60);
  var mins = totalMins - (hours * 60);
  return days + ' days ' + hours + ':' + mins;
}
