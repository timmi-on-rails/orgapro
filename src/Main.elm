module Main exposing (main)

import Browser
import Html
import IssuesPage
import Json.Encode as E
import LoginPage
import Next exposing (Next(..))
import UserSettings


main : Program E.Value Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


type Model
    = LoginPage LoginPage.Model
    | IssuesPage IssuesPage.Model


type Msg
    = LoginPageMsg LoginPage.Msg
    | IssuesPageMsg IssuesPage.Msg


init : E.Value -> ( Model, Cmd Msg )
init flags =
    UserSettings.decode flags
        |> Result.toMaybe
        |> LoginPage.init
        |> updateWith LoginPage LoginPageMsg




update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( LoginPage d, LoginPageMsg m ) ->
            LoginPage.update m d
                |> updateWith LoginPage LoginPageMsg

        ( IssuesPage d, IssuesPageMsg m ) ->
            IssuesPage.update m d
                |> updateWith IssuesPage IssuesPageMsg

        _ ->
            ( model, Cmd.none )



-- Workaround for compiler limitation
-- A function cannot be called recursive with different type parameters
-- see https://github.com/elm/compiler/issues/2275


updateWithRec : (subModel -> Model) -> (subMsg -> Msg) -> Next subModel subMsg -> ( Model, Cmd Msg )
updateWithRec =
    updateWith


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Next subModel subMsg -> ( Model, Cmd Msg )
updateWith toModel toMsg next =
    case next of
        Next ( subModel, subCmd ) ->
            ( toModel subModel
            , Cmd.map toMsg subCmd
            )

        GotoIssuesPage x ->
            IssuesPage.init x.settings (Just x.issues) |> updateWithRec IssuesPage IssuesPageMsg


view : Model -> Browser.Document Msg
view model =
    { title = "Orgapro"
    , body =
        [ case model of
            LoginPage d ->
                Html.map LoginPageMsg (LoginPage.view d)

            IssuesPage p ->
                Html.map IssuesPageMsg (IssuesPage.view p)
        ]
    }
