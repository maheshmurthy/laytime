function pad(val) {
  val += '';
  if(val.length == 1) {
    return "0" + val; 
  } else {
    return val;
  }
}

function buildDateTime(input_date, input_time, input_type) {
  var dateTime = {
    error: null, 
    parsedDate: null
  }
  var parsedDate= Date.parseExact(input_date, "dd.MM.yy");

  if(parsedDate == null) {
    dateTime.error = 'Please enter the date in format dd.mm.yy for ' + input_type;
    return dateTime;
  }

  var hr = parseInt(input_time.split('.')[0], 10);
  var min = parseInt(input_time.split('.')[1], 10);

  try {
    parsedDate.set({hour: hr, minute: min});
  } catch(error) {
    dateTime.error = 'Please make sure the hour and minute values are valid for ' + input_type;
    return dateTime;
  }
  dateTime.parsedDate = parsedDate;
  return dateTime;
}

function validateAndBuildInfo(operation) {
  var operationType = $(operation);
  var sofSet = operationType.getElementsByClassName('sof')[0];
  var length = sofSet.getElementsByClassName('row').length;

  var rows = sofSet.getElementsByClassName('row');

  var validity = doSofValidation(rows[0], operation);
  if(rows.length == 1) {
    return validity;
  }

  //if(validity.error != null && validity.error != "") {
  //  return validity;
  //}

  var usedMins = validity.mins;

  for(var i=0; i<rows.length-1; i++) {
    var sof1 = rows[i];
    var sof2 = rows[i+1];

    var validity = doSofValidation(rows[i], operation);
    if(validity.error != "") {
       return validity;
    }

    validity = doSofValidation(rows[i + 1], operation);
    if(validity.error != "") {
       return validity;
    }

    usedMins += validity.mins;

    var to_date = sof1.getElementsByClassName('time-info-text-date')[1].value;
    var to_time = sof1.getElementsByClassName('time-info-text-time')[1].value;
    var from_date = sof2.getElementsByClassName('time-info-text-date')[0].value;
    var from_time = sof2.getElementsByClassName('time-info-text-time')[0].value;

    if((to_date != from_date) || (to_time != from_time)) {
      validity.error = "The facts should be continuous. Please correct the from date of fact " + (i + 2) + " to match the until date of fact " + (i + 1) + " for " + operation;
      return validity;
    }
  }
  validity.mins = usedMins;
  return validity;
}

function doSofValidation(row, operation) {
  var info = {
    error: ''
  }

  var dateTime = buildDateTime(row.getElementsByClassName('time-info-text-date')[0].value, 
       row.getElementsByClassName('time-info-text-time')[0].value,
       "From");
   if(dateTime.parsedDate == null) {
     info.error = dateTime.error;
     return info;
   } else {
     from = dateTime.parsedDate;
   }

   dateTime = buildDateTime(row.getElementsByClassName('time-info-text-date')[1].value, 
      row.getElementsByClassName('time-info-text-time')[1].value,
      "Until");
   if(dateTime.parsedDate == null) {
     info.error = dateTime.error;
     return info;
   } else {
     to = dateTime.parsedDate;
   }

   if(from > to) {
     info.error = 'From can not be greater than Until. Please correct and try again';
     return info;
   }

   dateTime = buildDateTime($F(operation + '_time_start_date'), 
      $F(operation + '_time_start_time'),
      "Commence Date");

   if(dateTime.parsedDate == null) {
     info.error = dateTime.error;
     return info;
   } else {
     commence = dateTime.parsedDate;
   }
   
   dateTime = buildDateTime($F(operation + '_time_end_date'), 
      $F(operation + '_time_end_time'),
      "complete Date");

   if(dateTime.parsedDate == null) {
     info.error = dateTime.error;
     return info;
   } else {
     complete = dateTime.parsedDate;
   }

   /* from and to datetime should be greater than equal commence date and 
    less than equal complete date */

   if(from < commence) {
     info.error = 'From can not be less than laytime commence date';
     return info;
   }

   if(from >= complete) {
     info.error = 'From can not be greater than laytime complete date';
     return info;
   }

   if(to <= commence) {
     info.error = 'To can not be less than laytime commence date';
     return info;
   }

   if(to > complete) {
     info.error = 'To can not be greater than laytime complete date';
     return info;
   }

   var pct = row.getElementsByClassName('pct')[0].value;

   if(pct == "") {
     info.error = "Please enter percentage"; 
     return info;
   }

   var used = Math.round(((to - from)*(pct/100))/(1000*60));

   info.from = from;
   info.to = to;
   info.commence = commence;
   info.complete = complete;
   info.pct = pct;
   info.mins = used;

   return info;
}

function addRow(operation, action) {
  
  var val = validateAndBuildInfo(operation);

  if(val.error != "") {
    alert(val.error);
    return false;
  }
  var from_date = val.from;
  var from_time = from_date.getHours() + '.' + from_date.getMinutes();
  var to = val.to;
  var to_date = pad(to.getDate()) + "." + pad((to.getMonth() + 1)) + "." + (to.getFullYear()+'').substring(2);
  var to_time = to.getHours() + '.' + to.getMinutes();
  var commence = val.commence;
  var complete = val.complete;
  var operationType = $(operation);
  var sofSet = operationType.getElementsByClassName('sof')[0];
  var length = sofSet.getElementsByClassName('row').length;

  if(complete.compareTo(to) == 0) {
    // Don't error out if the action is a tab. We want to display the 
    // error only if user explicitly clicked on add row.
    if(action == "link") {
       alert("To is equal to Complete date");
    }
    return false;
  }
   /* 
    To of this sof is the from of next. 
    Get the to of the last sof and populate the from of new sof
   */

   var row = document.createElement('div')
   row.setAttribute('class','row');
   row.setAttribute('className','row');
   row.setAttribute('id', length);

   var img = document.createElement('img');
   img.setAttribute('alt', 'Cancel');
   img.setAttribute('class', 'cancel');
   img.setAttribute('className', 'cancel');
   img.setAttribute('id', length);
   img.setAttribute('src', '/images/cancel.png');
   img.onclick = function() { deleteRow(length)};
   row.appendChild(img);

   var label = document.createElement('label');
   label.setAttribute('id', 'from_' + operation + '_' + length);
   label.setAttribute('class','day');
   label.setAttribute('className','day');
   label.innerHTML = getDay(to);
   row.appendChild(label);

   var input = document.createElement('input');
   input.setAttribute('class','time-info-text-date');
   input.setAttribute('className','time-info-text-date');
   input.setAttribute('type','text');
   input.setAttribute('name',operation+'[][from_date]');
   input.setAttribute('id','from_date_'+operation+'_'+length);
   input.setAttribute('value',to_date);
   row.appendChild(input);

   input = document.createElement('input')
   input.setAttribute('class','time-info-text-time');
   input.setAttribute('className','time-info-text-time');
   input.setAttribute('type','text');
   var fromTimeId = 'from_time_' + operation + '_' + length;
   input.setAttribute('id', fromTimeId);
   input.setAttribute('name',operation+'[][from_time]');
   input.setAttribute('value',to_time);
   input.onblur = function() { validateTimeFormat(fromTimeId)};
   row.appendChild(input);

   var label = document.createElement('label');
   label.setAttribute('id', 'to_' + operation + '_' + length);
   label.setAttribute('class','day');
   label.setAttribute('className','day');
   label.innerHTML = "---";
   row.appendChild(label);

   input = document.createElement('input')
   input.setAttribute('class','time-info-text-date');
   input.setAttribute('className','time-info-text-date');
   input.setAttribute('type','text');
   input.setAttribute('id','to_date_'+operation+'_'+length);
   input.setAttribute('name',operation+'[][to_date]');
   input.setAttribute('value',"dd.mm.yy");
   input.onblur = function() { displayDayLabel(this.value, 'to', operation, length); };
   input.onfocus = function() {if(this.value == 'hh.mm' || this.value == 'dd.mm.yy') {this.value = '';}};
   row.appendChild(input);

   input = document.createElement('input')
   input.setAttribute('class','time-info-text-time');
   input.setAttribute('className','time-info-text-time');
   input.setAttribute('type','text');
   var toTimeId = 'to_time_' + operation + '_' + length;
   input.setAttribute('id', toTimeId);
   input.setAttribute('name',operation+'[][to_time]');
   input.setAttribute('value',"hh.mm");
   input.onfocus = function() {if(this.value == 'hh.mm' || this.value == 'dd.mm.yy') {this.value = '';}};
   input.onblur = function() { validateTimeFormat(toTimeId)};
   row.appendChild(input);

   input = document.createElement('select')
   var ttcId = 'ttc_' + operation + '_' + length;
   input.setAttribute('id', ttcId);
   input.setAttribute('name',operation+'[][timeToCount]');
   var TIME_TO_COUNT = ['Full/Normal', 'Rain/Bad Weather', 'Not to count', 'Shifting', 'Half', 'Partial', 'Always partial','Always excluded', 'Waiting','Full even if S/H', 'Partial even if S/H']
   for(var i=0; i<TIME_TO_COUNT.length; i++) {
     input.options[i] = new Option(TIME_TO_COUNT[i], TIME_TO_COUNT[i]);
   }
   row.appendChild(input);

   input = document.createElement('input')
   var pctId = 'pct_' + operation + '_' + length;
   input.setAttribute('id', pctId);
   input.setAttribute('class','pct');
   input.setAttribute('className','pct');
   input.setAttribute('type','text');
   input.setAttribute('name',operation+'[][val]');
   input.onblur = function() { updateRunningInfo(operation, length);};
   input.onfocus = function() { fillPct(ttcId);};
   row.appendChild(input);

   input = document.createElement('input')
   input.setAttribute('class','rem');
   input.setAttribute('className','rem');
   input.setAttribute('type','text');
   input.setAttribute('name',operation+'[][remarks]');
   input.onblur = function() { addRow(operation, 'tab')};
   row.appendChild(input);
   sofSet.appendChild(row);
}

function displayDayLabel(value, type, operation, index) {
  var element = $(type + '_' + operation + '_' + index);
  var d = Date.parseExact(value, "dd.MM.yy");
  element.innerHTML = getDay(d);
}

function autoFill(val, index, operation) {
  var start_date = $F(operation + '_time_start_date'); 
  var start_time = $F(operation + '_time_start_time');
  if(index == 0) {
    if(val == "date") {
      $('from_date_' + operation + '_' + index).value = start_date;
    } else {
      $('from_time_' + operation + '_' + index).value = start_time;
    }
  }
}

function getDay(d) {
  if(d) {
    return d.getDayName().substring(0,3);
  } else {
    return "---";
  }
}

function updateRunningInfo(operation, index) {
  var val = validateAndBuildInfo(operation);
  if(val.error != "") {
    alert(val.error);
    return false;
  }

  var from = val.from;
  var to = val.to;
  var commence = val.commence;
  var complete = val.complete;
  var operationType = $(operation);
  var sofSet = operationType.getElementsByClassName('sof')[0];
  var pct = val.pct;
  var usedMins = val.mins;

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
  var allowed = $(operation + '_allowed');
  allowed.innerHTML = "Total Time Allowed: " + diffString ;

  diffString = getDateDiffString(usedMins)
  var time_used = $(operation + '_used');
  time_used.innerHTML = "Time Used: " + diffString;

  var availMins = totalMins - usedMins
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
  return days + ' days ' + hours + '.' + mins;
}

function deleteRow(num) {
  num += '';
  if(window.confirm("Are you sure you want to delete this fact?" + num)) { 
    $(num).remove(); 
  }
}

function validateTimeFormat(ele) {
  var time = $F(ele);
  var regex = /[0-9][0-9]\.[0-9][0-9]/;
  if(!regex.test(time)) {
    alert("Please enter the time in format hh.mm");
    return false;
  }
  return true;
}

function validateDateFormat(ele) {
  var enteredDate = $F(ele);
  var regex = /[0-9][0-9]\.[0-9][0-9]\.[0-9][0-9]/;
  if(!regex.test(enteredDate)) {
    alert("Please enter the date in format dd.mm.yy");
    return false;
  }
  return true;
}

function fillPct(ele) {
  if($F(ele) == "Full/Normal") {
    // ele id is ttc_operation_counter. Replace ttc with pct and fill it with the value
    var pct = ele.replace('ttc', 'pct');
    $(pct).value = 100;
  }
}
