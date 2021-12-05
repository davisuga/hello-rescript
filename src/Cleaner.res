let initialDate = Js.Date.fromFloat(1638586800000.0)

let getTime = date => Js.Date.valueOf(date)->Belt.Float.toInt

let differenceInDays = (dateA, dateB) => {
  (getTime(dateB) - getTime(dateA)) / 86400000
}

type cleaner = [#Davi | #Cleto]

let getCleanerID = cleaner => {
  switch cleaner {
  | #Davi => "5c1c35db18c0b965ae717997"
  | #Cleto => "5b1f1cb8ce8d41f1841e81f7"
  }
}

let whoWillCleanTheSandbox = now => {
  if mod(differenceInDays(initialDate, now), 3) === 0 {
    Js.log("Cleto")

    #Cleto
  } else {
    Js.log("Davi")
    #Davi
  }
}
