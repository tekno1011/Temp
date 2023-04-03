import ballerina/io;
import ballerina/http;
import ballerina/mime;

listener http:Listener httpListener = new (8080);
listener http:Listener gitListener = new (9090);
map<string> headers={};
http:Client github = check new ("https://api.github.com");
string BASE_URL = "https://api.github.com";
string USER_RESOURCE_PATH = "/user";

//just for the testing main is implemented
// public function main() returns error?? {
//     string Owner = "DuminduHarshana";
//     string Reponame = "aeroAndroidApp";
//     json|error repodet = getrepodet(Owner, Reponame);
//     if repodet is json {
//        io:print(repodet);

//     // Result result = check repodet.cloneWithType();
//     // io:print(result.owner);
//     }
//     json|error repos = getrepos(Owner);
//     if repos is json {
//       io:print(repos);

//     }

// }
type Contributor record {
    string login;
    int contributions;
};

service /individual on httpListener {
    resource function get getAllContributors(string username, string reponame) returns Contributor[]|error {

        Contributor[] contributors = [];

        // Get the contributor details of the given username from the repository
        json[] user = check github->get("/repos/" + username + "/" + reponame + "/contributors");

        // Get the login name of the given contributor
        string contributorLogin = check user[0].login;
        io:print(contributorLogin);

        // Get the contributors of the repository
        json[] data = check github->get("/repos/" + username + "/" + reponame + "/contributors");
        string stringResult = data.toString();
        io:print(stringResult);
        // Iterate through the contributors array in the response and add each contributor to the 'contributors' array
        //      foreach var contributor in data {
        //      if ( check contributor.login.toString() != contributorLogin) {
        //         contributors.push({
        //              login: contributor["login"].toString(),
        //             contributions: <int>contributor["contributions"]
        //         });
        //      }
        // }

        return contributors;
    }

}

@http:ServiceConfig {

    cors: {
        allowOrigins: ["http://localhost:3000"],
        allowCredentials: true,
        allowMethods: ["GET", "POST", "OPTIONS"]
    }
}

service / on gitListener {

    resource function post githubLogin(@http:Payload map<json> token) returns json|error {
        string clientId = "00bba9c289b344fd4277";
        string clientSecret = "a6d137fa4ac43ca8ef77d5673cce9026a84a7e3d";
        string code = check token.token;
        json returnData = {};
        string j;
        do {
            json response = check github->post("/login/oauth/access_token",
            {

                client_id: clientId,
                client_secret: clientSecret,
                code: code
            },
            {
                Accept: mime:APPLICATION_JSON
            });

            returnData = {
                res: response

            };
            j = check response.access_token;
            io:print(j);
             headers = {
                "Accept": "application/vnd.github.v3+json",
                "Authorization": "Bearer" + j,
                "X-GitHub-Api-Version": "2022-11-28"
            };

        } on fail var err {
            returnData = {
                "message": err.toString()
            };
        }
        return returnData;
    }
}

service /getrepodetail on httpListener {

    resource function get getrepodet(string ownername, string reponame) returns json|error {

        json[] data;
        json returnData;
        do {
            data = check github->get(searchUrl(ownername, reponame));
            returnData = {
                ownername: ownername,
                reponame: reponame,
                commitCount: data.toString()
            };
        } on fail var e {
            returnData = {"message": e.toString()};
        }

        return returnData;

    }
}

function getrepos(string owner) returns json|error {
    json rpodata = check github->get(repoUrl(owner));
    io:print(rpodata);
}

service /getrepos on httpListener {
    resource function get getrepos(string ownername) returns json|error {
        json[] data;
        json returnData;
        do {
            data = check github->get("/users/" + ownername + "/repos");
            returnData = {
                ownername: ownername,
                reponame: data.toString()
            };
        } on fail var e {
            returnData = {"message": e.toString()};
        }

        return returnData;

    }

}

//function for appeding owner name and reponame
function searchUrl(string owner, string reponame) returns string {
    return "/repos/" + owner + "/" + reponame + "";

}

function repoUrl(string owner) returns string {
    return "/users/" + owner + "/repos";
}

service /getpullrq on httpListener {

    resource function get getCommitCount(string ownername, string reponame) returns json|error {

        json[] data;
        json returnData;
        do {
            data = check github->get("/repos/" + ownername + "/" + reponame + "/commits");
            returnData = {
                ownername: ownername,
                reponame: reponame,
                commitCount: data.length()
            };
        } on fail var e {
            returnData = {"message": e.toString()};
        }

        return returnData;
    }

    resource function get getPullRequestCount(string ownername, string reponame) returns json|error {

        json[] data;
        json returnData;
        do {
            data = check github->get("/repos/" + ownername + "/" + reponame + "/pulls", headers);
            returnData = {
                ownername: ownername,
                reponame: reponame,
                PullRequestCount: data.length()
            };
        } on fail var e {
            returnData = {"message": e.toString()};
        }

        return returnData;
    }
}
