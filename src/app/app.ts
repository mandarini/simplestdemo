import { Component, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { CommonModule } from '@angular/common';
import { AuthService } from './services/auth.service';
import { AuthComponent } from './components/auth/auth.component';
import { CatsListComponent } from './components/cats/cats-list.component';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, CommonModule, AuthComponent, CatsListComponent],
  template: `
    @if (authService.loading()) {
      <div class="loading-container">
        <div class="loading-spinner"></div>
        <p>Loading...</p>
      </div>
    } @else if (authService.user()) {
      <app-cats-list />
    } @else {
      <app-auth />
    }
    <router-outlet />
  `,
  styleUrl: './app.css'
})
export class App {
  constructor(protected authService: AuthService) {}
}
