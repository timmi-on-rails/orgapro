module LoginPage exposing (Model, Msg, init, update, view)

import Api
import Html exposing (button, fieldset, input, text)
import Html.Attributes exposing (disabled, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Issue exposing (Issue)
import Next exposing (Next(..))
import UserSettings exposing (UserSettings)


type alias Model =
    { projectUrl : String
    , apiKey : String
    , disabled : Bool
    }


type Msg
    = ApiKeyChanged String
    | ProjectUrlChanged String
    | CheckLoginData
    | DownloadComplete (Result Http.Error (List Issue))


init : Maybe UserSettings -> Next Model Msg
init settings =
    case settings of
        Just s ->
            Next
                ( { projectUrl = s.projectUrl, apiKey = s.apiKey, disabled = True }
                , Api.download DownloadComplete s.projectUrl s.apiKey
                )

        Nothing ->
            Next ( { projectUrl = "", apiKey = "", disabled = False }, Cmd.none )


update : Msg -> Model -> Next Model Msg
update msg model =
    case msg of
        ApiKeyChanged v ->
            Next ( { model | apiKey = v }, Cmd.none )

        ProjectUrlChanged v ->
            Next ( { model | projectUrl = v }, Cmd.none )

        CheckLoginData ->
            Next ( { model | disabled = True }, Api.download DownloadComplete model.projectUrl model.apiKey )

        DownloadComplete (Ok issues) ->
            GotoIssuesPage { issues = issues, settings = { projectUrl = model.projectUrl, apiKey = model.apiKey } }

        DownloadComplete (Err _) ->
            Next ( { model | disabled = False }, Cmd.none )


view : Model -> Html.Html Msg
view d =
    fieldset [ disabled d.disabled ]
        [ input [ onInput ProjectUrlChanged, value d.projectUrl ] []
        , input [ onInput ApiKeyChanged, value d.apiKey, type_ "password" ] []
        , button [ onClick CheckLoginData ] [ text "Let's go" ]
        ]
