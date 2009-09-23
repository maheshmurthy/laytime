function addrow() {
     var  set = document.getElementById('set');

     var row = document.createElement('div')
     row.setAttribute('class','row');

     var input = document.createElement('input')
     input.setAttribute('class','loc');
     input.setAttribute('type','textbox');
     input.setAttribute('name','fact_list[][from]');
     row.appendChild(input);

     input = document.createElement('input')
     input.setAttribute('class','loc');
     input.setAttribute('type','textbox');
     input.setAttribute('name','fact_list[][to]');
     row.appendChild(input);

     input = document.createElement('input')
     input.setAttribute('class','ttc');
     input.setAttribute('type','textbox');
     input.setAttribute('name','fact_list[][timeToCount]');
     row.appendChild(input);

     input = document.createElement('input')
     input.setAttribute('class','pct');
     input.setAttribute('type','textbox');
     input.setAttribute('name','fact_list[][val]');
     row.appendChild(input);

     input = document.createElement('input')
     input.setAttribute('class','rem');
     input.setAttribute('type','textbox');
     input.setAttribute('name','fact_list[][remarks]');
     row.appendChild(input);

     set.appendChild(row);
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
