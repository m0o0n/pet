import { Injectable } from '@nestjs/common'
import type { Todo } from './todo.entity'

@Injectable()
export class TodoService {
  private readonly todos: Todo[] = [
    { id: 1, title: 'Buy groceries', completed: false },
    { id: 2, title: 'Read a book', completed: true },
  ]

  findAll(): Todo[] {
    return this.todos
  }
}
