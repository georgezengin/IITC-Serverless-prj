import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { AuthService } from '../components/user/auth.service';
import { User } from '../models/user.model';

const baseUrl = 'https://8pqa3h8h7k.execute-api.eu-central-1.amazonaws.com/dev';
// const baseUrl = 'https://h1jpjncfdd.execute-api.eu-central-1.amazonaws.com/dev';

@Injectable({
  providedIn: 'root'
})
export class UserService {

  constructor(private http: HttpClient, private authService : AuthService) { }

  httpOptions = {
    headers: new HttpHeaders({
      "Content-Type": "application/json",
    }),
  };

  userLog():Observable<any>{
    this.authService.getAuthenticatedUser()?.getSession((err:any, session:any) =>{
      if(err)
      {
        console.log(err);
        return;
      }
      else
      {
        this.httpOptions = {
          headers: new HttpHeaders({
            "Content-Type": "application/json",
            Authorization: session.getIdToken().getJwtToken(),
          }),
        };     
      }
    } )
    let url = `${baseUrl}/user-log`
    return this.http.get(url , this.httpOptions);
  }

  getAll(): Observable<{
    Items: User [],
    Count: number,
    ScannedCount: number
  }> {
    this.authService.getAuthenticatedUser()?.getSession((err:any, session:any) =>{
      if(err)
      {
        console.log(err);
        return;
      }
      else
      {
        this.httpOptions = {
          headers: new HttpHeaders({
            "Content-Type": "application/json",
            Authorization: session.getIdToken().getJwtToken(),
          }),
        };     
      }
    } )
    let url = `${baseUrl}/users`
    return this.http.get<{
      Items: User [],
      Count: number,
      ScannedCount: number
    }>(url, this.httpOptions );
  }

  get(id: any): Observable<User> {
    this.authService.getAuthenticatedUser()?.getSession((err:any, session:any) =>{
      if(err)
      {
        console.log(err);
        return;
      }
      else
      {
        this.httpOptions = {
          headers: new HttpHeaders({
            "Content-Type": "application/json",
            Authorization: session.getIdToken().getJwtToken(),
          }),
        };     
      }
    } )

    let url = `${baseUrl}/users`
    return this.http.get<User>(`${url}?UserID=${id}`, this.httpOptions);
  }

}