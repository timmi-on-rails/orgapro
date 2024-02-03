module IssuesPage exposing (Model, Msg, init, update, view)

import Api
import Html exposing (a, button, div, text)
import Html.Attributes exposing (class, href, target)
import Html.Events exposing (onClick)
import Http
import Issue exposing (Issue, Priority(..))
import LoginPage exposing (Model)
import Next exposing (Next(..))
import UserSettings exposing (UserSettings)


type Model
    = Loading { settings : UserSettings }
    | Loaded
        { issues : List Issue
        , settings : UserSettings
        }


type Msg
    = DownloadComplete (Result Http.Error (List Issue))
    | CreateComplete (Result Http.Error Issue)
    | GotoLoginScreen
    | CreateIssue


init : UserSettings -> Maybe (List Issue) -> Next Model Msg
init settings issues =
    case issues of
        Just is ->
            Next ( Loaded { issues = is, settings = settings }, Cmd.none )

        Nothing ->
            Next ( Loading { settings = settings }, Api.download DownloadComplete settings.projectUrl settings.apiKey )


update : Msg -> Model -> Next Model Msg
update msg model =
    let
        settings =
            getSettings model
    in
    case msg of
        DownloadComplete (Ok t) ->
            Next ( Loaded { issues = t, settings = settings }, Cmd.none )

        DownloadComplete (Err _) ->
            Next ( model, Cmd.none )

        GotoLoginScreen ->
            -- TODO: show existing credentials
            -- ( LoginPage { projectUrl = "", apiKey = "", disabled = False }, Cmd.none )
            Next ( model, Cmd.none )

        CreateIssue ->
            Next ( model, Api.create CreateComplete { id = 0, title = "testNew", priority = LowPriority } settings.projectUrl settings.apiKey )

        CreateComplete (Ok _) ->
            -- TODO error handling
            Next ( model, Api.download DownloadComplete settings.projectUrl settings.apiKey )

        _ ->
            Next ( model, Cmd.none )


getSettings : Model -> UserSettings
getSettings model =
    case model of
        Loading m ->
            m.settings

        Loaded m ->
            m.settings


view : Model -> Html.Html Msg
view model =
    case model of
        Loading _ ->
            text "loading issues"

        Loaded m ->
            div
                [ class "board" ]
                [ button [ onClick CreateIssue ] [ text "new issue" ]
                , button [ onClick GotoLoginScreen ] [ text "login" ]
                , viewTable HighPriority m.issues
                , viewTable MediumPriority m.issues
                , viewTable LowPriority m.issues
                ]


viewTable : Priority -> List Issue -> Html.Html msg
viewTable prio ts =
    div
        [ class "issues-container" ]
        (ts |> List.filter (\x -> x.priority == prio) |> List.map viewIssue)


viewIssue : Issue -> Html.Html msg
viewIssue t =
    div [ class "issue-card" ]
        [ div []
            [ a
                [ href <| "https://redmine.linopro.de/issues/" ++ String.fromInt t.id
                , target "_blank"
                ]
                [ text <| "#" ++ String.fromInt t.id ]
            ]
        , div [] [ text <| t.title ]

        -- , div [] [ text <| t.priority ]
        ]
