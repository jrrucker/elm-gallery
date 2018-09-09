module Routing exposing (Route(..), matchers, parseLocation, pathFor)

import Images.Models exposing (ImageId, PersonId)
import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = HomeRoute
    | ImageRoute ImageId
    | PersonRoute PersonId
    | PersonImageRoute PersonId ImageId
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map HomeRoute top
        , map ImageRoute (s "image" </> int)
        , map PersonRoute (s "person" </> int)
        , map PersonImageRoute (s "person" </> int </> s "image" </> int)
        ]


parseLocation : Url -> Route
parseLocation url =
    let
        location =
            { url | path = url.fragment |> Maybe.withDefault "" }
    in
    parse matchers location
        |> Maybe.withDefault NotFoundRoute


pathFor : Route -> String
pathFor route =
    case route of
        PersonRoute personId ->
            "#/person/" ++ String.fromInt personId

        PersonImageRoute imageId personId ->
            "#/person/" ++ String.fromInt personId ++ "/image/" ++ String.fromInt imageId

        ImageRoute imageId ->
            "#/image/" ++ String.fromInt imageId

        HomeRoute ->
            "#"

        NotFoundRoute ->
            "#"
