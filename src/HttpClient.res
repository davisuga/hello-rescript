open Axios
open Promise
open Js.Array
open Cleaner

let apiKey = ""
let apiToken = ""

let params = "?key=" ++ apiKey ++ "&token=" ++ apiToken

type board = {name: string, id: string}

type card = {
  name: string,
  id: string,
  closed: bool,
  desc: string,
  idBoard: string,
  idList: string,
  idLabels: array<string>,
  idMembers: array<string>,
}

let getData = response => response["data"]

let getBoards = (): Promise.t<array<board>> =>
  get("https://api.trello.com/1/members/me/boards" ++ params)->thenResolve(getData)

let getCards = (withID: board): Promise.t<array<card>> =>
  get("https://api.trello.com/1/boards/" ++ withID.id ++ "/cards" ++ params)->thenResolve(getData)

let getHomeTasksBoard = find((board: board) => board.name === "Tarefas da casa", _)

exception BoardNotFound
exception CardNotFound
exception EmptyOption
type t<'a> = 'a constraint 'a = {..}

let optionToPromise = (optional: option<'a>) =>
  switch optional {
  | Some(data) => Promise.resolve(data)
  | None => Promise.reject(EmptyOption)
  }

let promisify = (f: 'inp => option<'out>, arg: 'inp) => optionToPromise(f(arg))

let updateCard = (updateData, id) =>
  putDatac(
    "https://api.trello.com/1/cards/" ++ id ++ params,
    {"": ""},
    makeConfig(~params=updateData, ()),
  )->thenResolve(getData)

type list = {name: string, id: string, closed: bool, idBoard: string, pos: int}

let getLists = (boardID: string): Promise.t<array<list>> =>
  get("https://api.trello.com/1/boards/" ++ boardID ++ "/lists" ++ params)->thenResolve(getData)

let _ = {
  let taskBoard = getBoards()->then(promisify(getHomeTasksBoard))
  let todayCleaner = whoWillCleanTheSandbox(Js.Date.make())->getCleanerID
  Js.log(todayCleaner)

  let list =
    taskBoard
    ->then(data => getLists(data.id))
    ->then(promisify(find((list: list) => list.name === "To do", _)))

  let card =
    taskBoard
    ->then(getCards)
    ->then(promisify(find((card: card) => card.name === "Limpar a areia dos gatos")))
    ->then(card =>
      list->then(listID =>
        updateCard(
          {
            "idList": listID,
            "idMembers": todayCleaner,
          },
          card.id,
        )
      )
    )

  Promise.all2((list, card))->thenResolve(Js.log)
  //   ->thenResolve(Js.log)
  // ->catch(Js.log)
}

//   switch cards {
//   | Some(cardList) => cardList->
//   | None => reject(CardNotFound)
//   },

// {
//     id: '61aae01a51052c264830fc8b',
//     checkItemStates: [],
//     closed: false,
//     dateLastActivity: '2021-12-04T15:31:40.705Z',
//     desc: '',
//     descData: { emoji: {} },
//     dueReminder: null,
//     idBoard: '61aadde28580cb1b2a94b474',
//     idList: '61aade072f70a3561cf2b4c1',
//     idMembersVoted: [],
//     idShort: 4,
//     idAttachmentCover: null,
//     idLabels: [ '61aadea0b72d0802ef3926b1' ],
//     manualCoverAttachment: false,
//     name: 'Limpar a areia dos gatos',
//     pos: 16384,
//     shortLink: 'uOeUDAKP',
//     isTemplate: false,
//     cardRole: null,
//     dueComplete: false,
//     due: null,
//     email: null,
//     shortUrl: 'https://trello.com/c/uOeUDAKP',
//     start: null,
//     url: 'https://trello.com/c/uOeUDAKP/4-limpar-a-areia-dos-gatos',
//     cover: {
//       idAttachment: null,
//       color: null,
//       idUploadedBackground: null,
//       size: 'normal',
//       brightness: 'dark',
//       idPlugin: null
//     },
//     idMembers: [ '5b1f1cb8ce8d41f1841e81f7' ],
//     labels: [ [Object] ],
//     badges: {
//       attachmentsByType: [Object],
//       location: false,
//       votes: 0,
//       viewingMemberVoted: false,
//       subscribed: false,
//       fogbugz: '',
//       checkItems: 0,
//       checkItemsChecked: 0,
//       checkItemsEarliestDue: null,
//       comments: 0,
//       attachments: 0,
//       description: false,
//       due: null,
//       dueComplete: false,
//       start: null
//     },
//     subscribed: false,
//     idChecklists: []
//   }
