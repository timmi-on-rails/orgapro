module Next exposing (Next(..))

import Issue exposing (Issue)
import UserSettings exposing (UserSettings)


type Next model message
    = Next ( model, Cmd message )
    | GotoIssuesPage
        { issues : List Issue
        , settings : UserSettings
        }
