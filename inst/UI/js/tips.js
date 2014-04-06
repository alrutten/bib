
tip = [];

tip[0] = "When printing the map of tomorrow already today remember to change the date !" ;
tip[1] = "If there are bugs in the data your daily map could be wrong or incomplete!";
tip[2] = "LAYING_START and HATCHING_START columns are redundant but they serve as a double check!";
tip[3] = "Press the reload button of F5 to see the latest map!";
tip[4] = "Close and open the page to see if there are new bugs!";

index = Math.floor(Math.random() * tip.length);

document.write("<a><i class='fa fa-comment'></i>"  + tip[index] + "</a>");


