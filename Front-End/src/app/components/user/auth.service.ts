import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { Subject } from 'rxjs';
import { Observable } from 'rxjs';
import { BehaviorSubject } from 'rxjs';
import { User } from './user.model';
import { AuthenticationDetails, CognitoUser, CognitoUserAttribute, CognitoUserPool, CognitoUserSession, ISignUpResult } from 'amazon-cognito-identity-js'

const POOL_DATA = {
  UserPoolId : "eu-central-1_Y8ubLO6cS",
  ClientId:"33cu99fr1qmv524pnj3mlsefjk"
}

// const POOL_DATA = {
//   UserPoolId : "eu-central-1_vlNVFypvD",
//   ClientId:"545jf21a4miekicekd95i3vruc"
// }

const userPool = new CognitoUserPool(POOL_DATA);

@Injectable()
export class AuthService {
  authIsLoading = new BehaviorSubject<boolean>(false);
  authDidFail = new BehaviorSubject<boolean>(false);
  authMessage = new BehaviorSubject<{message: string | null}>({message: null});
  authStatusChanged = new Subject<boolean>();
  
  constructor(private router : Router) {}
  signUp(username: string, email: string, password: string, name : string): void {
    this.authIsLoading.next(true);
    const user: User = {
      username,
      email,
      password
    };
    
    const emailAttribute = {
      Name: 'email',
      Value: email
    };

    const nameAttribute = {
      Name: 'name', 
      Value: name
    }

    const attrList : CognitoUserAttribute[] = [];
    const validationList : CognitoUserAttribute[] = [];

    attrList.push(new CognitoUserAttribute(emailAttribute), new CognitoUserAttribute(nameAttribute));

    var that = this;
    userPool.signUp(user.username, user.password, attrList, validationList, function (
      error: Error | undefined,
      result : ISignUpResult | undefined
    ) {
      if (error) {
        that.authDidFail.next(true)
        that.authIsLoading.next(false)
        that.authMessage.next({message: error.message})
        console.log(error.message || JSON.stringify(error));
        return;
      }
      that.authDidFail.next(false)
      that.authIsLoading.next(false)
      var cognitoUser = result?.user;
      console.log('user name is ' + cognitoUser?.getUsername());
    });
    return;
  }
  confirmUser(username: string, code: string) {
    var that = this;
    this.authIsLoading.next(true);
    var userData = {
      Username: username,
      Pool: userPool,
    };
    var router = this.router
    var cognitoUser = new CognitoUser(userData);
    cognitoUser.confirmRegistration(code, true, function(error, result) {
      if (error) {
        that.authDidFail.next(true)
        that.authIsLoading.next(false)
        that.authMessage.next({message: error.message})
        console.log(error.message || JSON.stringify(error));
        return;
      }
      else
      {
        that.authDidFail.next(false)
        that.authIsLoading.next(false)
      router.navigate(['/']);
      console.log('call result: ' + result);
      }
    });
  }
  signIn(username: string, password: string): void {
    var that = this;
    this.authIsLoading.next(true);
    const authData = {
      Username: username,
      Password: password
    };

    const authDetails = new AuthenticationDetails(authData);
    var userData = {
      Username: username,
      Pool: userPool,
    };
    var cogUser = new CognitoUser(userData);
    cogUser.authenticateUser(authDetails,  {
       onSuccess(result: CognitoUserSession){
        that.authStatusChanged.next(true)
        that.authDidFail.next(false)
        that.authIsLoading.next(false)
        console.log(result);
       },
       onFailure(error){
        that.authDidFail.next(true)
        that.authMessage.next({message: error.message})
        that.authIsLoading.next(false)
        console.log(error);
       }
    })
    return;
  }
  getAuthenticatedUser() {
    return userPool.getCurrentUser();
  }
  logout() {
    this.getAuthenticatedUser()?.signOut();
    this.authStatusChanged.next(false);
  }
  isAuthenticated(): Observable<boolean> {
    const user = this.getAuthenticatedUser();
    const obs = Observable.create((observer : any) => {
      if (!user) {
        observer.next(false);
      } else {
        user.getSession((err : any, session: any) =>{
          if(err)
          {
            observer.next(false);
          }
          else
          {
            if(session.isValid())
            {
              observer.next(true);
            }
            else
            {
              observer.next(false);
            }
          }
        } )
      }
      observer.complete();
    });
    return obs;
  }
  initAuth() {
    this.isAuthenticated().subscribe(
      (auth) => this.authStatusChanged.next(auth)
    );
  }
}
