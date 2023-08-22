import { Component, OnInit } from '@angular/core';
import { AuthService } from './components/user/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit{
  title = 'AngularCognitoApp';
  isAuthenticated = false;

  constructor(private authService: AuthService,
    private router: Router) {
}

  ngOnInit(): void {
    this.authService.authStatusChanged.subscribe(
      (authenticated) => {
        this.isAuthenticated = authenticated;
        if (authenticated) {
          this.router.navigate(['/users']);
        } else {
          this.router.navigate(['/']);
        }
      }
    );
    this.authService.initAuth();
  }

  onLogout() {
    this.authService.logout();
  }

}
