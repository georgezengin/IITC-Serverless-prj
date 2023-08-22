import { Component, OnInit } from '@angular/core';
import { User } from 'src/app/models/user.model';
import { UserService } from 'src/app/services/user.service';

@Component({
  selector: 'app-users-list',
  templateUrl: './users-list.component.html',
  styleUrls: ['./users-list.component.css']
})
export class UsersListComponent implements OnInit {

  users?: User [];
  currentUser: User = {};
  currentIndex = -1;
  title = '';
  messageToUser = null;

  show = true;

	close() {
		this.show = false;
	}

  constructor(private userService: UserService) { }

  ngOnInit(): void {
    this.userLogIn();
    this.retrieveUsers();
  }

  userLogIn():void {
    this.userService.userLog().subscribe((messageToUser) => this.messageToUser = messageToUser);
  }

  retrieveUsers(): void {
    this.userService.getAll()
      .subscribe({
        next: ({Items}) => {
          this.users = Items;
          console.log(Items);
        },
        error: (e) => console.error(e)
      });
  }

  refreshList(): void {
    this.retrieveUsers();
    this.currentUser = {};
    this.currentIndex = -1;
  }

  setActiveUser(user: User, index: number): void {
    this.currentUser = user;
    this.currentIndex = index;
  }

}