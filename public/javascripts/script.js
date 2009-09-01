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
