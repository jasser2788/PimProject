const getWord = () => {
    const adjectives = [
     " people	",
      "history	",
      "way"	,
      "art	",
      "world"	,
      "information	",
"      map	",
      "two	",
      "family",	
      "government",	
     " health"	,
      "system"	,
      "meat"	,
      "year"	,
      	
     
    ];
  
    return adjectives[Math.floor(Math.random() * adjectives.length)];
  };
  
  module.exports = getWord;