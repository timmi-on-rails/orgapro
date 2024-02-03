module Issue exposing (Issue, Priority(..))


type Priority
    = LowPriority
    | MediumPriority
    | HighPriority


type alias Issue =
    { id : Int
    , title : String
    , priority : Priority
    }
