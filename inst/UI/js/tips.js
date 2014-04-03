
tip = [];

tip[0] = "When printing the map of tomorrow already today remember to change the date !" ;
tip[1] = "If there are bugs in the data your daily map could be wrong or incomplete!";
tip[2] = "LAYING_START and HATCHING_START columns are redundant but they serve as a double check!";
tip[3] = "Press the reload button of F5 to see the latest map; if this does not work close and open your browser or clear the cache!";

index = Math.floor(Math.random() * tip.length);

document.write("<a>TIP: "  + tip[index] + "</a>");


