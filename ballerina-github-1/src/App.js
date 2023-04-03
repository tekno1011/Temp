import React, { Component } from 'react';

import GitHubLogin from 'react-github-login';


class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      token: null,
      error: null
    };
  }

  onSuccessGithub = (response) => {
    this.setState({
      token: response.code,
      error: null
    });
    this.sendTokenToEndpoint(response.code);
  }

  sendTokenToEndpoint = (token) => {
    fetch('http://localhost:9090/githubLogin', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        token: token
      })
    })
    .then(response => {
      if (response.ok) {
        console.log('Token sent successfully.');
      } else {
        throw new Error('Failed to send token.');
      }
    })
    .catch(error => {
      console.error(error);
      this.setState({
        token: null,
        error: error.message
      });
    });
  }

 
  render() {
    return (
      <div className="App" align="center">
        <h1>LOGIN WITH GITHUB </h1>
        {this.state.token ?
          <p>Token: {this.state.token}</p>
          :
          <GitHubLogin clientId="00bba9c289b344fd4277"
            onSuccess={this.onSuccessGithub}
            buttonText="LOGIN WITH GITHUB"
            className="git-login"
            valid={true}
            redirectUri="http://localhost:3000"
          />
        }
        {this.state.error &&
          <p>Error: {this.state.error}</p>
        }
      </div>
    );
  }
}

export default App;
