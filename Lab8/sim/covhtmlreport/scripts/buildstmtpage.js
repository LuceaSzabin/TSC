var tables = document.getElementsByTagName("TABLE");
var table = tables[tables.length - 1]; // the table contains the show/hide buttons may or may not exist
var cells = table.rows[0].cells;
var prevRow;
var isIE = true;

function makeHttpObject() {
	try {
		return new ActiveXObject("Msxml2.XMLHTTP");
	} catch (e) {
		try {
			return new ActiveXObject("Microsoft.XMLHTTP");
		} catch (e) {
			try {
				isIE = false;
				return new XMLHttpRequest();
			} catch (e) {
				alert("Error: HTTP request object could not be created. Please try different browser");
			}
		}
	}

	throw new Error("Could not create HTTP request object.");
}
var request = makeHttpObject();

try {
	request.open("GET", table.id, false);
	request.send(null);
} catch (e) {
	alert("Error: HTTP request could not be created. Make sure that the source file \""+table.id+"\" exists\nIf the problem persists, try different browser");
}

if (isIE) {
	var xmlDocument = new ActiveXObject("Microsoft.XMLDOM");
	xmlDocument.async = "false";
	try {
		if (!xmlDocument.loadXML(request.responseText))
		throw e;
	} catch(e) {
		alert("Error: in loading the source page \""+table.id+"\"");
	}
	ttNode = xmlDocument.documentElement.childNodes[1].childNodes[0];
} else {
	try {
		var sourcePage = request.responseXML.documentElement;
		ttNode = sourcePage.childNodes[3].childNodes[1];
	} catch (e) {
		alert("Error: in loading the source page \""+table.id+"\"");
	}
}

for (var i = 0; i < cells.length; i++) {
	var dataInCells = cells[i].innerHTML.match(/^([^$]+)\$([^$]*)\$([^$]*)$/i);
	var newRow = document.createElement('TR');
	var newCells = [];
	for (var n = 0; n <= 3; n++) {
		newCells[n] = document.createElement('TD');
		if (n == 3) {
			var link = [];
			if (!newCells[1].innerHTML.match(/^\.\d+$/)) {
				// line that doesn't contain item number
				newCells[n].innerHTML = "";
				if (dataInCells[2+1].match(/^class="Y"$/)) {
					newCells[2].innerHTML = "";
					newCells[n].className = 'Y';
				} else if (hrefData = dataInCells[2+1].match(/^.+\.htm[l]?$/)) {
					newCells[2].innerHTML = "";
					link[dataInCells[0+1]] = hrefData[0];
				}

				var passedLines = 0;
				for (var c=0; c < ttNode.childNodes.length - 1; c++) {
					if (ttNode.childNodes[c].nodeName.match(/^a$/i) && ttNode.childNodes[c].getAttribute("name")) {
						passedLines++;
						if ( passedLines == dataInCells[0+1]) {
							c += 2;
							for (;(! ttNode.childNodes[c].nodeName.match(/^br$/i)) && (c < ttNode.childNodes.length - 1);c++) {
								var newNode = ttNode.childNodes[c].cloneNode(true);
								try {
									if (newNode.childNodes.length>1 && newNode.childNodes[1].nodeName.match(/^a$/i) && newNode.childNodes[1].getAttribute("href") && link[dataInCells[0+1]]) {
										//alert(link[dataInCells[0+1]]);
										newNode.childNodes[1].setAttribute("href",link[dataInCells[0+1]]);
										//link[dataInCells[0+1]] = null;
									}
									newCells[n].appendChild(newNode);
								} catch (e) {
									// IE ..... 
									if (ttNode.childNodes[c].nodeType == 3) {
										// text node
										var tmp = document.createTextNode(ttNode.childNodes[c].nodeValue);
									} else if (ttNode.childNodes[c].nodeType == 1) {
										var tmp = document.createElement(ttNode.childNodes[c].nodeName);
										if (ttNode.childNodes[c].getAttribute("class"))
											tmp.className = ttNode.childNodes[c].getAttribute("class");
										
										var innerV = document.createTextNode(ttNode.childNodes[c].childNodes[0].nodeValue);
										tmp.appendChild(innerV);
										
										if (ttNode.childNodes[c].childNodes.length>1 && ttNode.childNodes[c].childNodes[1].nodeName.match(/^a$/i) && ttNode.childNodes[c].childNodes[1].getAttribute("href") && link[dataInCells[0+1]]) {
											var innerA = document.createElement("a");
											innerA.setAttribute("href",link[dataInCells[0+1]]);
											innerA.innerHTML = ttNode.childNodes[c].childNodes[1].childNodes[0].nodeValue;
											tmp.appendChild(innerA);
										}
									}
									newCells[n].appendChild(tmp);
								}
							}
							break;
						}
					}
				}
			} else {
				newCells[n].innerHTML = "";
			}
		} else {
			newCells[n].innerHTML = dataInCells[n+1];
		}
		newRow.appendChild(newCells[n]);
	}
	table.tBodies[0].appendChild(newRow);
	
	var tmp = document.createElement('A');
	tmp.name = newRow.cells[0].innerHTML;
	newRow.cells[0].appendChild(tmp);
	newRow.cells[0].className = 'srcLine';
	newRow.cells[1].className = 'srcStmt';
		
	newRow.cells[3].innerHTML = newRow.cells[3].innerHTML.replace(/%s%/g,"&nbsp;");
	newRow.cells[3].innerHTML = newRow.cells[3].innerHTML.replace(/%t%/g,"&nbsp;&nbsp;&nbsp;&nbsp;");
	
	if (newRow.cells[2].innerHTML.match(/^\d+$/)) {
		if (newRow.cells[2].innerHTML > 0) {
			newRow.cells[2].className = 'covGreen';
			newRow.className = 'covered';
			if(newRow.cells[1].innerHTML.match(/^\.\d+$/)) {
				newRow.cells[3].innerHTML = "&nbsp;";
				newRow.cells[3].className = 'srcNorm';
			} else /*if(newRow.cells[1].innerHTML == "&nbsp;")*/ {
				newRow.cells[1].innerHTML = "&nbsp;";
				newRow.cells[3].className = 'srcGreen';
			}
		} else if (newRow.cells[2].innerHTML == '0') {
			newRow.cells[2].className = 'covRed';
			newRow.className = 'missing';
			if(newRow.cells[1].innerHTML.match(/^\.\d+$/)) {
				newRow.cells[3].className = 'srcNorm';
				newRow.cells[3].innerHTML = "&nbsp;";
			} else /*if(newRow.cells[1].innerHTML == "&nbsp;")*/ {
				newRow.cells[1].innerHTML = "&nbsp;";
				newRow.cells[3].className = 'srcRed';
			}
		}
	} else {
		newRow.cells[1].innerHTML = "&nbsp;";
		newRow.cells[2].innerHTML = "&nbsp;";
		newRow.cells[2].className = 'covNorm';
		if (i>0) {
			// so that prevRow has a value
			if (prevRow.className == 'neutral') {
				newRow.className = 'neutral';
				newRow.cells[3].className = 'srcNorm';
			} else if (newRow.cells[3].className == 'Y') {
				newRow.cells[3].className = 'srcYellow';
			} else if (prevRow.className == 'covered' && prevRow.cells[1].innerHTML.match(/^\.\d+$/)) {
				newRow.className = 'covered';
				newRow.cells[3].className = 'srcGreen';
			} else if (prevRow.className == 'missing' && prevRow.cells[1].innerHTML.match(/^\.\d+$/)) {
				newRow.className = 'missing';
				newRow.cells[3].className = 'srcRed';
			} else {
				newRow.className = 'neutral';
				newRow.cells[3].className = 'srcNorm';
			}
		} else {
			newRow.className = 'neutral';
			newRow.cells[3].className = 'srcNorm';
		}
	}
	prevRow = newRow;
}
// remove the row that contained the compressed data
table.tBodies[0].removeChild(table.rows[0]);
// add the 100 </br> at the end of the html page
var body = document.getElementsByTagName("BODY")[0];
for (var j = 0; j < 100; j++) {
	var br = document.createElement('BR');
	body.appendChild(br);
}
