module Api exposing (create, download)

import Http
import Issue exposing (Issue, Priority(..))
import Json.Decode as D exposing (Decoder, field, int, string)
import Json.Encode as E


download : (Result Http.Error (List Issue) -> msg) -> String -> String -> Cmd msg
download m projectUrl apiKey =
    let
        q =
            projectUrl ++ "/issues.json?key=" ++ apiKey
    in
    Http.get
        { url = "/get" ++ "?q=" ++ q
        , expect = Http.expectJson m issuesDecoder
        }


create : (Result Http.Error Issue -> msg) -> Issue -> String -> String -> Cmd msg
create m issue projectUrl apiKey =
    let
        q =
            projectUrl ++ "/issues.json?key=" ++ apiKey

        body =
            Http.jsonBody (issueEncoder issue)
    in
    Http.post
        { url = "/post" ++ "?q=" ++ q
        , expect = Http.expectJson m issueDecoder
        , body = body
        }


issuesDecoder : Decoder (List Issue)
issuesDecoder =
    D.field "issues"
        (D.list <| issueDecoderRaw)


issueDecoder : Decoder Issue
issueDecoder =
    D.field "issue" issueDecoderRaw


issueDecoderRaw : Decoder Issue
issueDecoderRaw =
    D.map3 Issue
        (field "id" int)
        (field "subject" string)
        (field "priority"
            (field "name" string
                |> D.andThen
                    (\x ->
                        case x of
                            "Niedrig" ->
                                D.succeed LowPriority

                            "Normal" ->
                                D.succeed MediumPriority

                            "Hoch" ->
                                D.succeed HighPriority

                            _ ->
                                D.fail ("unknown priority " ++ x)
                    )
            )
        )


issueEncoder : Issue -> E.Value
issueEncoder issue =
    E.object [ ( "issue", issueEncoderRaw issue ) ]


issueEncoderRaw : Issue -> E.Value
issueEncoderRaw issue =
    E.object
        [ ( "subject", E.string issue.title )
        ]
